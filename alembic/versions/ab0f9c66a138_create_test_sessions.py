"""create test sessions

Revision ID: ab0f9c66a138
Revises: 995c97fff635
Create Date: 2025-12-27 11:09:28.727216

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'ab0f9c66a138'
down_revision: Union[str, Sequence[str], None] = '995c97fff635'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        'careerprofile_test_sessions',
        sa.Column('id', sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column('user_id', sa.BigInteger(), nullable=False),
        sa.Column('riasec_completed', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('ikigai_completed', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('status', sa.String(length=50), server_default='riasec_pending', nullable=False),
        sa.Column('started_at', sa.TIMESTAMP(), server_default=sa.text('now()'), nullable=False),
        sa.Column('completed_at', sa.TIMESTAMP(), nullable=True),

        # Definisi Primary Key
        sa.PrimaryKeyConstraint('id'),
    )

    op.create_index('idx_test_sessions_user', 'careerprofile_test_sessions', ['user_id'])
    op.create_index('idx_test_sessions_status', 'careerprofile_test_sessions', ['status'])

def downgrade() -> None:
    """Downgrade schema."""
    op.drop_table('careerprofile_test_sessions')