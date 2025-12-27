import httpx
import asyncio
from app.core.config import settings
from app.core.metrics import ai_request_counter, ai_response_time, ai_cost_tracker
import structlog

logger = structlog.get_logger()

class GeminiFlashClient:
    def __init__(self):
        self.api_key = settings.OPENROUTER_API_KEY
        self.base_url = settings.OPENROUTER_BASE_URL
        self.model = settings.OPENROUTER_MODEL
        self.timeout = 30

    async def chat_completion(
            self,
            messages: list,
            max_tokens: int = 2000,
            temperature: float = 0.7,
            dimension: str = "general"
    ) -> str:
        """
        Generic LLM call

        Args:
            messages: List of {role: "user"/"system", content: "..."}
            max_tokens: Max response length
            temperature: Creativity level
            dimension: For metrics tracking

        Returns:
            Generated text
        """
        retry_count = 0
        max_retries = 3

        while retry_count <= max_retries:
            try:
                # Measure response time
                with ai_response_time.labels(dimension=dimension).time():
                    async with httpx.AsyncClient() as client:
                        response = await client.post(
                            f"{self.base_url}/chat/completions",
                            headers={
                                "Authorization": f"Bearer {self.api_key}",
                                "Content-Type": "application/json",
                                "HTTP-Referer": "http://localhost:8000",  # OpenRouter sering minta ini
                                "X-Title": "My FastAPI App",  # Opsional tapi disarankan
                            },
                            json={
                                "model": self.model,
                                "messages": messages,
                                "max_tokens": max_tokens,
                                "temperature": temperature
                            },
                            timeout=self.timeout
                        )

                        response.raise_for_status()
                        data = response.json()

                        # Extract response
                        generated_text = data["choices"][0]["message"]["content"]

                        # Track metrics
                        ai_request_counter.labels(
                            dimension=dimension,
                            status="success"
                        ).inc()

                        logger.info(
                            "ai_request_success",
                            dimension=dimension,
                            retry_count=retry_count
                        )

                        return generated_text

            except httpx.TimeoutException:
                retry_count += 1
                logger.warning(
                    "ai_request_timeout",
                    dimension=dimension,
                    retry_count=retry_count
                )
                if retry_count <= max_retries:
                    await asyncio.sleep(2 * retry_count)  # Exponential backoff
                    continue

            except httpx.HTTPStatusError as e:
                if e.response.status_code == 429:  # Rate limit
                    retry_count += 1
                    wait_time = 2 ** retry_count
                    logger.warning(
                        "ai_rate_limit_hit",
                        wait_seconds=wait_time
                    )
                    if retry_count <= max_retries:
                        await asyncio.sleep(wait_time)
                        continue

                # Other HTTP errors - don't retry
                logger.error("ai_request_http_error", status_code=e.response.status_code)
                break

        # All retries failed
        ai_request_counter.labels(dimension=dimension, status="failed").inc()
        raise Exception(f"AI request failed after {retry_count} retries")


# Singleton instance
gemini_client = GeminiFlashClient()