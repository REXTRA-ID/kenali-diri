from pydantic import BaseModel


class CategoryResponse(BaseModel):
    id: int
    category_code: str
    category_name: str
    description: str | None
    is_active: bool

    class Config:
        from_attributes = True
