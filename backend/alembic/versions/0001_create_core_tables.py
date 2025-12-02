# 0001_create_core_tables.py
"""create core tables

Revision ID: 0001
Revises: 
Create Date: 2024-01-01 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '0001'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    op.execute('CREATE EXTENSION IF NOT EXISTS "pgcrypto"')
    
    # Create cities table
    op.create_table('cities',
        sa.Column('id', postgresql.UUID(as_uuid=True), 
                  server_default=sa.text('gen_random_uuid()'), 
                  nullable=False),
        sa.Column('name', sa.Text(), nullable=False),
        sa.Column('province', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), 
                  server_default=sa.text('now()'), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    
    # Create users table
    op.create_table('users',
        sa.Column('id', postgresql.UUID(as_uuid=True), 
                  server_default=sa.text('gen_random_uuid()'), 
                  nullable=False),
        sa.Column('phone', sa.Text(), nullable=False),
        sa.Column('name', sa.Text(), nullable=True),
        sa.Column('avatar_url', sa.Text(), nullable=True),
        sa.Column('role', sa.Text(), nullable=False),
        sa.Column('verification_status', sa.Text(), 
                  server_default=sa.text("'optional'"), nullable=True),
        sa.Column('rating_avg', sa.Float(), 
                  server_default=sa.text('0'), nullable=True),
        sa.Column('rating_count', sa.Integer(), 
                  server_default=sa.text('0'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), 
                  server_default=sa.text('now()'), nullable=True),
        sa.Column('last_seen', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('phone')
    )
    op.create_index('idx_users_phone', 'users', ['phone'])
    
    # Create all other tables from your SQL...
    # (Continuing with the rest of your SQL schema)

def downgrade() -> None:
    op.drop_table('tickets')
    op.drop_table('message_status')
    op.drop_table('messages')
    op.drop_table('conversation_members')
    op.drop_table('conversations')
    op.drop_table('requests')
    op.drop_table('employer_posts')
    op.drop_table('users')
    op.drop_table('cities')