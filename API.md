# 财务仓储系统 — API 文档

## 启动服务

```bash
cd wms-server
php -S 0.0.0.0:8080 index.php
```

**Base URL**: `http://localhost:8080`

---

## 认证

所有业务接口需在 Header 带 Token：
```
Authorization: Bearer <token>
```

### POST /api/auth/login — 登录

```json
{
  "username": "admin",
  "password": "123456"
}
```

响应：
```json
{
  "code": 0,
  "data": {
    "token": "eyJ...",
    "username": "admin",
    "role": "super_admin"
  }
}
```

---

## 基础资料

### 产品管理

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/products?keyword=&page= | 产品列表 |
| POST | /api/products | 新增产品 |
| PUT | /api/products | 更新产品 |
| DELETE | /api/products?id=1 | 删除产品 |

新增产品请求体：
```json
{
  "product_code": "PROD-001",
  "product_name": "陶瓷杯",
  "category": "成品",
  "unit": "个",
  "remark": ""
}
```

### SKU 规格管理

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/skus?product_id=1 | 规格列表 |
| POST | /api/skus | 新增规格 |
| PUT | /api/skus | 更新规格 |
| DELETE | /api/skus?id=1 | 删除规格 |

新增 SKU：
```json
{
  "product_id": 1,
  "sku_code": "SKU-001",
  "spec_name": "500ml/白色",
  "color": "白色",
  "size": "500ml",
  "price": 29.90,
  "cost_price": 15.00,
  "safety_stock": 10
}
```

### 其他

| 方法 | 路径 | 说明 |
|------|------|------|
| GET/POST | /api/warehouses | 仓库列表/新增 |
| GET/POST/PUT | /api/salespersons | 销售人员 |
| GET/POST/PUT | /api/customers | 客户管理 |

---

## 核心业务

### POST /api/productions — 生产入库

```json
{
  "sku_id": 1,
  "quantity": 100,
  "unit_cost": 12.50,
  "total_cost": 1250,
  "production_date": "2026-07-10",
  "batch_no": "B20260710",
  "remark": ""
}
```
> 创建后自动：库存 +100，写入库存流水，更新移动加权成本

### GET /api/productions?start_date=&end_date=&page= — 生产列表

---

### POST /api/sales — 销售出库

```json
{
  "salesperson_id": 1,
  "customer_id": 1,
  "sale_date": "2026-07-10",
  "paid_amount": 100,
  "items": [
    { "sku_id": 1, "quantity": 5, "unit_price": 29.90 },
    { "sku_id": 2, "quantity": 3, "unit_price": 19.90 }
  ]
}
```
> 创建后自动：库存减少，写入流水，更新客户应收账款

### GET /api/sales?start_date=&end_date=&salesperson_id=&page= — 销售列表

### GET /api/sales/export?start_date=2026-07-01&end_date=2026-07-31 — 导出 CSV

---

### GET /api/inventory?keyword=&low_stock=1 — 库存查询

### GET /api/inventory-logs?sku_id=&change_type=&start_date=&end_date= — 库存流水

---

### 收付款

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/payments | 列表 |
| POST | /api/payments | 新增收付款 |

```json
{
  "payment_type": "receivable",
  "amount": 500,
  "customer_id": 1,
  "related_order_id": 3,
  "payment_method": "微信",
  "payment_date": "2026-07-10"
}
```

---

### GET /api/dashboard — 仪表盘统计

返回：
```json
{
  "today_sales": 12345.00,
  "month_sales": 234567.00,
  "month_production": 5000,
  "inventory_value": 150000.00,
  "receivable": 35000.00,
  "low_stock_count": 3,
  "today_orders": 15,
  "sales_trend_7d": [...],
  "top_stock": [...],
  "top_sales": [...]
}
```
