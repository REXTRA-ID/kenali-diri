"""create kenalidiri tables

Revision ID: 1a2b3c4d5e6f
Revises:

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '1a2b3c4d5e6f'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # 1. Create Table: kenalidiri_categories
    op.create_table(
        'kenalidiri_categories',
        sa.Column('id', sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column('category_code', sa.String(length=50), nullable=False),
        sa.Column('category_name', sa.String(length=100), nullable=False),
        sa.Column('description', sa.String(length=500), nullable=True),
        sa.Column('detail_table_name', sa.String(length=100), nullable=True),
        sa.Column('is_active', sa.Boolean(), server_default=sa.text('true'), nullable=True),
        sa.Column('created_at', sa.TIMESTAMP(), server_default=sa.text('now()'), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('category_code')
    )

    # 2. Create Table: kenalidiri_history
    op.create_table(
        'kenalidiri_history',
        sa.Column('id', sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column('user_id', sa.BigInteger(), nullable=False),
        sa.Column('category_id', sa.BigInteger(), nullable=False),
        sa.Column('result_summary', sa.Text(), nullable=True),
        sa.Column('created_at', sa.TIMESTAMP(), server_default=sa.text('now()'), nullable=True),

        # Foreign Key
        sa.ForeignKeyConstraint(['category_id'], ['kenalidiri_categories.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )

    # 3. Create Indexes
    op.create_index('idx_history_user', 'kenalidiri_history', ['user_id'], unique=False)
    op.create_index('idx_history_category', 'kenalidiri_history', ['category_id'], unique=False)


def downgrade():
    # Drop indexes first
    op.drop_index('idx_history_category', table_name='kenalidiri_history')
    op.drop_index('idx_history_user', table_name='kenalidiri_history')

    # Drop tables in reverse order (Child first, then Parent)
    op.drop_table('kenalidiri_history')
    op.drop_table('kenalidiri_categories')