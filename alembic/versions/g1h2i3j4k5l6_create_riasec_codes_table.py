"""create riasec codes table

Revision ID: g1h2i3j4k5l6
Revises: ff5587c56feb
Create Date: 2025-12-30 17:15:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = 'g1h2i3j4k5l6'
down_revision: Union[str, Sequence[str], None] = 'ff5587c56feb'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """
    Create riasec_codes table for Holland's RIASEC personality types
    """
    op.create_table(
        'riasec_codes',
        sa.Column('id', sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column('riasec_code', sa.String(length=10), nullable=False),
        sa.Column('riasec_title', sa.String(length=100), nullable=False),
        sa.Column('riasec_description', sa.Text(), nullable=True),
        
        # JSONB arrays for flexible data
        sa.Column('strengths', postgresql.JSONB(astext_type=sa.Text()), 
                  server_default='[]', nullable=False),
        sa.Column('challenges', postgresql.JSONB(astext_type=sa.Text()), 
                  server_default='[]', nullable=False),
        sa.Column('strategies', postgresql.JSONB(astext_type=sa.Text()), 
                  server_default='[]', nullable=False),
        sa.Column('work_environments', postgresql.JSONB(astext_type=sa.Text()), 
                  server_default='[]', nullable=False),
        sa.Column('interaction_styles', postgresql.JSONB(astext_type=sa.Text()), 
                  server_default='[]', nullable=False),
        sa.Column('congruent_code_ids', postgresql.JSONB(astext_type=sa.Text()), 
                  server_default='[]', nullable=False),
        
        sa.Column('created_at', sa.DateTime(timezone=True), 
                  server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), 
                  server_default=sa.text('now()'), nullable=False),
        
        # Primary Key
        sa.PrimaryKeyConstraint('id'),
        
        # Unique constraint on riasec_code
        sa.UniqueConstraint('riasec_code', name='uq_riasec_codes_code')
    )
    
    # Create index for fast lookups
    op.create_index(
        'idx_riasec_codes_code',
        'riasec_codes',
        ['riasec_code'],
        unique=True
    )


def downgrade() -> None:
    """Drop riasec_codes table and indexes"""
    op.drop_index('idx_riasec_codes_code', table_name='riasec_codes')
    op.drop_table('riasec_codes')
