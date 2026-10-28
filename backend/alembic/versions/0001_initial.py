"""initial tables

Revision ID: 0001_initial
Revises: 
Create Date: 2026-10-28
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = '0001_initial'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        'users',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('password_hash', sa.String(length=255), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=True),
        sa.Column('age', sa.Integer(), nullable=True),
        sa.Column('height_cm', sa.Integer(), nullable=True),
        sa.Column('daily_calorie_target', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
    )
    op.create_index('ix_users_email', 'users', ['email'], unique=True)

    op.create_table(
        'food_items',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('calories_per_100g', sa.Float(), nullable=False),
        sa.Column('protein_per_100g', sa.Float(), nullable=False),
        sa.Column('fat_per_100g', sa.Float(), nullable=False),
        sa.Column('carbs_per_100g', sa.Float(), nullable=False),
    )
    op.create_index('ix_food_items_name', 'food_items', ['name'], unique=False)

    op.create_table(
        'meal_logs',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('food_item_id', sa.Integer(), sa.ForeignKey('food_items.id'), nullable=True),
        sa.Column('meal_type', sa.String(length=50), nullable=True),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('grams', sa.Float(), nullable=False),
        sa.Column('calories', sa.Float(), nullable=False),
        sa.Column('protein', sa.Float(), nullable=False),
        sa.Column('fat', sa.Float(), nullable=False),
        sa.Column('carbs', sa.Float(), nullable=False),
        sa.Column('eaten_at', sa.DateTime(), nullable=True),
    )


def downgrade() -> None:
    op.drop_table('meal_logs')
    op.drop_index('ix_food_items_name', table_name='food_items')
    op.drop_table('food_items')
    op.drop_index('ix_users_email', table_name='users')
    op.drop_table('users')
