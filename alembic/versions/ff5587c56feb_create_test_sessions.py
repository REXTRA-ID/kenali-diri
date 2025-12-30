"""create test sessions

Revision ID: ff5587c56feb
Revises: 1a2b3c4d5e6f
Create Date: 2025-12-27 14:28:34.146717

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'ff5587c56feb'
down_revision: Union[str, Sequence[str], None] = '0a1b2c3d4e5f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    # 1. Create Table: careerprofile_test_sessions
    op.create_table(
        'careerprofile_test_sessions',
        sa.Column('id', sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column('user_id', sa.BigInteger(), nullable=False),
        sa.Column('status', sa.String(length=20), server_default='IN_PROGRESS', nullable=False),
        sa.Column('current_step', sa.Integer(), server_default='1', nullable=False),
        sa.Column('started_at', sa.TIMESTAMP(), server_default=sa.text('now()'), nullable=True),
        sa.Column('completed_at', sa.TIMESTAMP(), nullable=True),
        sa.Column('results_data', sa.JSON(), nullable=True),  # Menyimpan hasil mentah tes

        # Primary Key
        sa.PrimaryKeyConstraint('id'),

        # Foreign Key ke tabel users
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE')
    )

    # 2. Tambah Indexes
    op.create_index('idx_test_sessions_user', 'careerprofile_test_sessions', ['user_id'], unique=False)
    op.create_index('idx_test_sessions_status', 'careerprofile_test_sessions', ['status'], unique=False)


def downgrade():
    # 1. Drop Indexes
    op.drop_index('idx_test_sessions_status', table_name='careerprofile_test_sessions')
    op.drop_index('idx_test_sessions_user', table_name='careerprofile_test_sessions')

    # 2. Drop Table
    op.drop_table('careerprofile_test_sessions')