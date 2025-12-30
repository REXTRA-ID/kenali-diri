"""create digital professions table

Revision ID: e686239bb63f
Revises: ff5587c56feb
Create Date: 2025-12-30 17:20:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'e686239bb63f'
down_revision: Union[str, Sequence[str], None] = 'g1h2i3j4k5l6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """
    Create digital_professions table
    
    This table stores digital profession data with:
    - Strict core columns (title, description, RIASEC mapping)
    - Flexible JSONB metadata for tech_stack, frameworks, seniority, etc.
    """
    # Create table
    op.create_table(
        'digital_professions',
        sa.Column('id', sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column('title', sa.String(length=255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('riasec_code_id', sa.BigInteger(), nullable=False),
        sa.Column(
            'meta_data',
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default='{}'
        ),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=False
        ),
        sa.Column(
            'updated_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=False
        ),
        
        # Primary Key
        sa.PrimaryKeyConstraint('id'),
        
        # Foreign Key to riasec_codes table
        sa.ForeignKeyConstraint(
            ['riasec_code_id'],
            ['riasec_codes.id'],
            ondelete='RESTRICT'
        ),
        
        # Unique constraint on title
        sa.UniqueConstraint('title', name='uq_digital_professions_title')
    )
    
    # Create indexes for performance
    op.create_index(
        'idx_digital_professions_title',
        'digital_professions',
        ['title'],
        unique=False
    )
    op.create_index(
        'idx_digital_professions_riasec_code_id',
        'digital_professions',
        ['riasec_code_id'],
        unique=False
    )
    
    # Create GIN index on JSONB column for fast querying
    op.create_index(
        'idx_digital_professions_meta_data',
        'digital_professions',
        ['meta_data'],
        unique=False,
        postgresql_using='gin'
    )


def downgrade() -> None:
    """Drop digital_professions table and its indexes"""
    # Drop indexes first
    op.drop_index('idx_digital_professions_meta_data', table_name='digital_professions')
    op.drop_index('idx_digital_professions_riasec_code_id', table_name='digital_professions')
    op.drop_index('idx_digital_professions_title', table_name='digital_professions')
    
    # Drop table
    op.drop_table('digital_professions')
