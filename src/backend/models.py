"""
SQLAlchemy Models - Schema completo do banco de dados
"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, DECIMAL, Text, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base


class Company(Base):
    """Empresas/Clientes"""
    __tablename__ = "companies"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    cnpj = Column(String(18), unique=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    employees = relationship("Employee", back_populates="company")
    users = relationship("User", back_populates="company")


class Employee(Base):
    """Funcionários"""
    __tablename__ = "employees"

    id = Column(Integer, primary_key=True, index=True)
    company_id = Column(Integer, ForeignKey("companies.id"))
    employee_code = Column(String(50), unique=True, nullable=False, index=True)
    name = Column(String(255), nullable=False)
    cpf = Column(String(14), unique=True)
    email = Column(String(255))
    phone = Column(String(20))
    department = Column(String(100))
    position = Column(String(100))
    biometric_hash = Column(Text)  # Hash da digital
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    company = relationship("Company", back_populates="employees")
    punch_records = relationship("PunchRecord", back_populates="employee")


class PunchRecord(Base):
    """Registros de Ponto"""
    __tablename__ = "punch_records"

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(Integer, ForeignKey("employees.id"), nullable=False)
    timestamp = Column(DateTime(timezone=True), nullable=False, index=True)
    latitude = Column(DECIMAL(10, 8))
    longitude = Column(DECIMAL(11, 8))
    location_address = Column(Text)
    device_id = Column(String(255))
    biometric_verified = Column(Boolean, default=False)
    photo_url = Column(Text)  # URL da foto (opcional)
    status = Column(String(50), default='valid')  # valid, invalid, pending_review
    synced_at = Column(DateTime(timezone=True), server_default=func.now())
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    employee = relationship("Employee", back_populates="punch_records")


class User(Base):
    """Usuários Admin (para painel web)"""
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(100), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(50), default='viewer')  # admin, manager, viewer
    company_id = Column(Integer, ForeignKey("companies.id"))
    last_login = Column(DateTime(timezone=True))
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    company = relationship("Company", back_populates="users")
    audit_logs = relationship("AuditLog", back_populates="user")


class AuditLog(Base):
    """Logs de Auditoria"""
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    action = Column(String(100), nullable=False)
    entity_type = Column(String(50))
    entity_id = Column(Integer)
    details = Column(JSON)
    ip_address = Column(String(45))  # IPv6 support
    user_agent = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    # Relationships
    user = relationship("User", back_populates="audit_logs")
