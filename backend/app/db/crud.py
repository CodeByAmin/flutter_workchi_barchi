# app/db/crud.py
from sqlalchemy.orm import Session
from . import models
from uuid import UUID
from typing import Optional, List
from sqlalchemy import select

def get_user_by_phone(db: Session, phone: str) -> Optional[models.User]:
    return db.query(models.User).filter(models.User.phone == phone).one_or_none()

def get_user_by_id(db: Session, user_id: str) -> Optional[models.User]:
    return db.query(models.User).filter(models.User.id == user_id).one_or_none()

def create_user(db: Session, phone: str, role: str = "worker", name: str | None = None) -> models.User:
    user = models.User(phone=phone, role=role, name=name)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

def get_or_create_user_by_phone(db: Session, phone: str, role: str = "worker") -> models.User:
    user = get_user_by_phone(db, phone)
    if user:
        return user
    return create_user(db, phone=phone, role=role)

# Employer posts / job posts
def create_employer_post(db: Session, employer_id: str, title: str, description: str, city_id: str, salary: float | None = None) -> models.EmployerPost:
    post = models.EmployerPost(employer_id=employer_id, title=title, description=description, city_id=city_id, salary=salary)
    db.add(post)
    db.commit()
    db.refresh(post)
    return post

def get_post_by_id(db: Session, post_id: str) -> Optional[models.EmployerPost]:
    return db.query(models.EmployerPost).filter(models.EmployerPost.id == post_id).one_or_none()

def list_posts_for_city(db: Session, city_id: Optional[str]=None, limit:int=50, offset:int=0):
    q = db.query(models.EmployerPost).filter(models.EmployerPost.status == "open")
    if city_id:
        q = q.filter(models.EmployerPost.city_id == city_id)
    return q.order_by(models.EmployerPost.created_at.desc()).offset(offset).limit(limit).all()

# Requests (worker applies)
def create_request(db: Session, worker_id: str, post_id: str, employer_id: str, message: str | None = None):
    req = models.Request(worker_id=worker_id, post_id=post_id, employer_id=employer_id)
    db.add(req)
    db.commit()
    db.refresh(req)
    return req

def list_requests_by_worker(db: Session, worker_id: str):
    return db.query(models.Request).filter(models.Request.worker_id == worker_id).order_by(models.Request.created_at.desc()).all()

def list_requests_for_employer(db: Session, employer_id: str):
    return db.query(models.Request).filter(models.Request.employer_id == employer_id).order_by(models.Request.created_at.desc()).all()

# Conversations & messages
def create_conversation(db: Session, is_group: bool = False):
    conv = models.Conversation(is_group=is_group)
    db.add(conv)
    db.commit()
    db.refresh(conv)
    return conv

def add_member_to_conversation(db: Session, conversation_id: str, user_id: str):
    member = models.ConversationMember(conversation_id=conversation_id, user_id=user_id)
    db.add(member)
    db.commit()
    return member

def list_conversations_for_user(db: Session, user_id: str):
    conv_ids = db.query(models.ConversationMember.conversation_id).filter(models.ConversationMember.user_id == user_id)
    return db.query(models.Conversation).filter(models.Conversation.id.in_(conv_ids)).all()

def create_message(db: Session, conversation_id: str, sender_id: str, message_text: str, message_type: str = "text"):
    msg = models.Message(conversation_id=conversation_id, sender_id=sender_id, message=message_text, message_type=message_type)
    db.add(msg)
    db.commit()
    db.refresh(msg)
    return msg

def list_messages(db: Session, conversation_id: str, limit: int = 100, offset: int = 0):
    return db.query(models.Message).filter(models.Message.conversation_id == conversation_id).order_by(models.Message.created_at.asc()).offset(offset).limit(limit).all()

# Market items
def list_market_items(db: Session, limit: int = 50, offset: int = 0):
    from .models import MarketItem
    return db.query(MarketItem).filter(MarketItem.available == True).order_by(MarketItem.created_at.desc()).offset(offset).limit(limit).all()
