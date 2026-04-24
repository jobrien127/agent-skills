# Mermaid Examples: Real-World Scenarios

Practical examples of Mermaid diagrams for common use cases in software development, system design, and project management.

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Microservices Architecture](#microservices-architecture)
3. [Authentication Flow](#authentication-flow)
4. [API Request-Response Sequence](#api-request-response-sequence)
5. [Database Design](#database-design)
6. [User Registration Process](#user-registration-process)
7. [Order Processing Workflow](#order-processing-workflow)
8. [Application State Machine](#application-state-machine)
9. [CI/CD Pipeline](#cicd-pipeline)
10. [Project Timeline](#project-timeline)
11. [Class Hierarchy - Design Patterns](#class-hierarchy---design-patterns)
12. [Git Workflow](#git-workflow)
13. [User Onboarding Journey](#user-onboarding-journey)
14. [Feature Dependency Graph](#feature-dependency-graph)
15. [Network Packet Structure](#network-packet-structure)

---

## System Architecture

**Use Case**: Documenting a three-tier web application architecture.

```mermaid
graph TB
    Client["🖥️ Client Layer<br/>Web Browser"]

    subgraph "🔄 Load Balancer"
        LB["Nginx Load Balancer"]
    end

    subgraph "📱 Application Layer"
        API1["API Server 1<br/>Node.js/Express"]
        API2["API Server 2<br/>Node.js/Express"]
        API3["API Server 3<br/>Node.js/Express"]
    end

    subgraph "💾 Cache Layer"
        Cache["Redis Cache<br/>Session & Data Cache"]
    end

    subgraph "🗄️ Data Layer"
        PrimaryDB["PostgreSQL<br/>Primary"]
        ReplicaDB["PostgreSQL<br/>Replica"]
    end

    Client --> LB
    LB --> API1
    LB --> API2
    LB --> API3
    API1 --> Cache
    API2 --> Cache
    API3 --> Cache
    API1 --> PrimaryDB
    API2 --> PrimaryDB
    API3 --> PrimaryDB
    PrimaryDB --> ReplicaDB

    style Client fill:#e1f5ff
    style LB fill:#fff3e0
    style API1 fill:#f3e5f5
    style API2 fill:#f3e5f5
    style API3 fill:#f3e5f5
    style Cache fill:#e8f5e9
    style PrimaryDB fill:#fce4ec
    style ReplicaDB fill:#fce4ec
```

**When to Use**:
- Presenting infrastructure to stakeholders
- Documenting deployment architecture
- Planning scalability discussions

---

## Microservices Architecture

**Use Case**: Showing independent microservices and their communication patterns.

```mermaid
graph TB
    User["👤 End User"]
    Gateway["🚪 API Gateway<br/>Kong/Nginx"]

    subgraph "User Service"
        UserSvc["User Microservice<br/>Port 3001"]
        UserDB[(User DB<br/>MongoDB)]
    end

    subgraph "Product Service"
        ProdSvc["Product Microservice<br/>Port 3002"]
        ProdDB[(Product DB<br/>PostgreSQL)]
        ProdCache["Product Cache<br/>Redis"]
    end

    subgraph "Order Service"
        OrderSvc["Order Microservice<br/>Port 3003"]
        OrderDB[(Order DB<br/>PostgreSQL)]
    end

    subgraph "Payment Service"
        PaySvc["Payment Microservice<br/>Port 3004"]
    end

    Queue["📨 Message Queue<br/>RabbitMQ"]

    User --> Gateway
    Gateway --> UserSvc
    Gateway --> ProdSvc
    Gateway --> OrderSvc
    UserSvc --> UserDB
    ProdSvc --> ProdDB
    ProdSvc --> ProdCache
    OrderSvc --> OrderDB
    OrderSvc --> Queue
    PaySvc --> Queue

    style Gateway fill:#fff3e0
    style Queue fill:#ffe0b2
    style UserSvc fill:#f3e5f5
    style ProdSvc fill:#e1f5fe
    style OrderSvc fill:#e8f5e9
    style PaySvc fill:#fce4ec
```

**When to Use**:
- Communicating microservices architecture
- Planning service boundaries
- Documenting inter-service communication

---

## Authentication Flow

**Use Case**: OAuth 2.0 authentication with third-party provider.

```mermaid
sequenceDiagram
    participant User as 👤 User
    participant Browser as 🌐 Browser
    participant App as 📱 Our App
    participant OAuth as 🔐 OAuth Provider

    User->>Browser: Click "Login with Google"
    Browser->>App: Request /auth/google
    App->>OAuth: Redirect to OAuth provider
    OAuth->>Browser: Show login form
    User->>Browser: Enter credentials
    Browser->>OAuth: Submit login
    OAuth->>OAuth: Verify credentials
    OAuth->>Browser: Redirect to callback
    Browser->>App: GET /callback?code=XXX
    App->>OAuth: POST token request<br/>with code
    OAuth->>App: Return access_token
    App->>App: Create session
    App->>Browser: Set session cookie
    Browser->>User: Redirect to dashboard
```

**When to Use**:
- Documenting authentication flows
- Explaining OAuth/SAML integration
- Planning security architecture

---

## API Request-Response Sequence

**Use Case**: Typical REST API interaction with error handling.

```mermaid
sequenceDiagram
    participant Client as Client App
    participant Server as API Server
    participant Auth as Auth Service
    participant DB as Database

    Client->>Server: GET /api/users/123
    Server->>Auth: Verify JWT token
    alt Token Valid
        Auth-->>Server: ✓ Token valid
        Server->>DB: SELECT user WHERE id=123
        DB-->>Server: User data
        Server-->>Client: 200 OK {user data}
    else Token Expired
        Auth-->>Server: ✗ Token expired
        Server-->>Client: 401 Unauthorized
    else Invalid Token
        Auth-->>Server: ✗ Token invalid
        Server-->>Client: 403 Forbidden
    end

    Note over Client,Server: Authentication flow ensures<br/>only authorized requests proceed
```

**When to Use**:
- Documenting API specifications
- Explaining error handling
- Planning error recovery

---

## Database Design

**Use Case**: E-commerce database schema.

```mermaid
erDiagram
    CUSTOMER ||--o{ ORDER : places
    CUSTOMER ||--o{ REVIEW : writes
    ORDER ||--|{ ORDER_ITEM : contains
    ORDER_ITEM }o--|| PRODUCT : includes
    PRODUCT ||--o{ REVIEW : receives
    PRODUCT }o--|| CATEGORY : "belongs to"
    CATEGORY ||--o{ PRODUCT : contains
    PRODUCT ||--o{ INVENTORY : tracks
    ORDER ||--o{ PAYMENT : receives
    ORDER ||--o{ SHIPMENT : has

    CUSTOMER {
        int id PK
        string email UK "Unique"
        string password_hash
        string first_name
        string last_name
        text address
        string phone
        datetime created_at
        datetime updated_at
    }

    PRODUCT {
        int id PK
        string name
        text description
        float price
        int stock_quantity
        int category_id FK
        datetime created_at
    }

    ORDER {
        int id PK
        int customer_id FK
        float total_amount
        string status
        datetime order_date
        datetime shipped_date
    }

    ORDER_ITEM {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
        float unit_price
    }

    CATEGORY {
        int id PK
        string name UK
        text description
    }

    INVENTORY {
        int id PK
        int product_id FK UK
        int quantity_available
        int quantity_reserved
        datetime last_updated
    }

    PAYMENT {
        int id PK
        int order_id FK
        float amount
        string method
        string status
        datetime processed_at
    }

    SHIPMENT {
        int id PK
        int order_id FK
        string carrier
        string tracking_number
        datetime shipped_date
        datetime delivered_date
    }

    REVIEW {
        int id PK
        int customer_id FK
        int product_id FK
        int rating
        text comment
        datetime created_at
    }
```

**When to Use**:
- Database schema documentation
- Planning database migrations
- Explaining data relationships

---

## User Registration Process

**Use Case**: Complete user registration workflow with validation.

```mermaid
flowchart TD
    Start([User Visits Signup]) --> Form["📝 Display Signup Form"]
    Form --> Submit["User Submits Data"]
    Submit --> Validate{Data<br/>Valid?}

    Validate -->|No| ValidateError["❌ Show Error<br/>Messages"]
    ValidateError --> Form

    Validate -->|Yes| CheckEmail{Email<br/>Exists?}
    CheckEmail -->|Yes| EmailError["❌ Email Already<br/>Registered"]
    EmailError --> Form

    CheckEmail -->|No| HashPass["🔐 Hash Password"]
    HashPass --> CreateUser["👤 Create User<br/>Record"]
    CreateUser --> CheckSuccess{Record<br/>Created?}

    CheckSuccess -->|No| DbError["❌ Database<br/>Error"]
    DbError --> Form

    CheckSuccess -->|Yes| SendEmail["📧 Send<br/>Verification Email"]
    SendEmail --> EmailSent["✓ Email Sent"]
    EmailSent --> Verify["🔗 User Verifies<br/>Email"]
    Verify --> VerifyCheck{Email<br/>Verified?}

    VerifyCheck -->|No| NotVerified["⏳ Verification<br/>Pending"]
    NotVerified --> Verify

    VerifyCheck -->|Yes| CreateSession["🔐 Create Session"]
    CreateSession --> Redirect["↪️ Redirect to<br/>Dashboard"]
    Redirect --> End([✓ Registration<br/>Complete])

    style Start fill:#e8f5e9
    style End fill:#e8f5e9
    style ValidateError fill:#ffebee
    style EmailError fill:#ffebee
    style DbError fill:#ffebee
    style CreateSession fill:#c8e6c9
```

**When to Use**:
- Documenting onboarding flows
- Planning error handling
- Communicating business logic

---

## Order Processing Workflow

**Use Case**: Order fulfillment state machine.

```mermaid
stateDiagram-v2
    [*] --> PendingPayment: Order Placed

    PendingPayment --> PaymentFailed: Payment Declined
    PaymentFailed --> PendingPayment: User Retries
    PaymentFailed --> Cancelled: User Gives Up

    PendingPayment --> Paid: Payment Successful
    Paid --> Processing: Order Confirmed
    Processing --> Shipped: Packed & Handed<br/>to Carrier
    Shipped --> Delivered: Delivered<br/>to Customer

    Delivered --> Complete: Order<br/>Finished

    Processing --> BackorderNeeded: Out of Stock
    BackorderNeeded --> Shipped: Stock<br/>Replenished

    Shipped --> Lost: Lost<br/>in Transit
    Lost --> Refunded: Refund<br/>Issued

    Complete --> [*]
    Cancelled --> [*]
    Refunded --> [*]
```

**When to Use**:
- Documenting order fulfillment
- Planning state transitions
- Handling business edge cases

---

## Application State Machine

**Use Case**: Multi-step wizard or form state management.

```mermaid
stateDiagram-v2
    [*] --> Welcome

    Welcome --> PersonalInfo: Start
    PersonalInfo --> ContactInfo: Next
    PersonalInfo --> Welcome: Back

    ContactInfo --> Address: Next
    ContactInfo --> PersonalInfo: Back

    Address --> BillingAddress: Same as<br/>Shipping
    Address --> BillingAddress: Different
    Address --> ContactInfo: Back

    BillingAddress --> Review: Next
    BillingAddress --> Address: Back

    Review --> Submit: Confirm
    Review --> BillingAddress: Back

    Submit --> Processing: Submitting...
    Processing --> Success: Success!
    Processing --> Error: Error

    Error --> Review: Edit
    Error --> Welcome: Start Over

    Success --> [*]
```

**When to Use**:
- Managing complex form workflows
- Planning multi-step processes
- Documenting state transitions

---

## CI/CD Pipeline

**Use Case**: Automated deployment pipeline.

```mermaid
graph LR
    Commit["📝 Developer<br/>Commits Code"]
    Build["🔨 Build<br/>Application"]
    Test["🧪 Run Tests"]
    Lint["✓ Code Quality<br/>Check"]
    DockerBuild["🐳 Build Docker<br/>Image"]
    Registry["📦 Push to<br/>Registry"]
    StageDeploy["🚀 Deploy<br/>to Staging"]
    StageTest["🧪 Smoke Tests<br/>on Staging"]
    Approval["👤 Manual<br/>Approval"]
    ProdDeploy["🚀 Deploy<br/>to Production"]
    Monitor["📊 Monitor<br/>Health"]

    Commit --> Build
    Build --> Test
    Test --> Lint

    Lint -->|Pass| DockerBuild
    Lint -->|Fail| Failure["❌ Pipeline<br/>Failed"]

    DockerBuild --> Registry
    Registry --> StageDeploy
    StageDeploy --> StageTest

    StageTest -->|Fail| Failure
    StageTest -->|Pass| Approval

    Approval -->|Approved| ProdDeploy
    Approval -->|Rejected| End["⏹️ Stopped"]

    ProdDeploy --> Monitor
    Monitor -->|Healthy| Success["✓ Deployment<br/>Complete"]
    Monitor -->|Issues| Rollback["↶ Rollback"]
    Rollback --> Success

    style Commit fill:#e1f5fe
    style Success fill:#e8f5e9
    style Failure fill:#ffebee
    style Approval fill:#fff3e0
```

**When to Use**:
- Documenting deployment processes
- Planning automation strategies
- Communicating release procedures

---

## Project Timeline

**Use Case**: Software project phases and milestones.

```mermaid
gantt
    title Product Development Timeline (Q1-Q2 2024)
    dateFormat YYYY-MM-DD

    section Requirements
    Requirements Gathering    :req1, 2024-01-01, 14d
    Stakeholder Review        :req2, after req1, 7d
    Final Sign-off            :crit, req3, after req2, 3d

    section Design
    System Architecture       :des1, after req3, 14d
    UI/UX Design              :des2, after req3, 21d
    Design Review             :crit, des3, after des2, 3d

    section Development
    Backend Development       :dev1, after des1, 30d
    Frontend Development      :dev2, after des3, 25d
    Integration Work          :dev3, after dev1 dev2, 10d

    section Testing
    Unit Testing              :test1, after dev1, 7d
    Integration Testing       :test2, after dev3, 10d
    UAT                       :test3, after test2, 14d
    Bug Fixes                 :test4, after test3, 7d

    section Deployment
    Beta Release              :milestone, 2024-05-01, 0d
    Production Release        :crit, milestone, 2024-05-15, 0d
    Post-Launch Support       :sup1, after 2024-05-15, 14d
```

**When to Use**:
- Planning project timelines
- Tracking milestones
- Communicating schedules to stakeholders

---

## Class Hierarchy - Design Patterns

**Use Case**: Factory pattern implementation.

```mermaid
classDiagram
    class PaymentProcessor {
        <<interface>>
        +process(amount: float)
        +refund(amount: float)
    }

    class CreditCardProcessor {
        -apiKey: string
        +process(amount: float)
        +refund(amount: float)
    }

    class PayPalProcessor {
        -clientId: string
        -clientSecret: string
        +process(amount: float)
        +refund(amount: float)
    }

    class StripeProcessor {
        -secretKey: string
        +process(amount: float)
        +refund(amount: float)
    }

    class PaymentFactory {
        +createProcessor(type: string): PaymentProcessor
    }

    class Order {
        -orderId: string
        -processor: PaymentProcessor
        +pay(amount: float)
    }

    PaymentProcessor <|.. CreditCardProcessor
    PaymentProcessor <|.. PayPalProcessor
    PaymentProcessor <|.. StripeProcessor

    PaymentFactory ..> PaymentProcessor
    Order --> PaymentProcessor
```

**When to Use**:
- Documenting design patterns
- Explaining class relationships
- Planning refactoring

---

## Git Workflow

**Use Case**: Feature branch Git workflow (simplified).

```mermaid
gitGraph
    commit id: "v1.0.0 Release"
    commit id: "Initial commit for v1.1"

    branch develop
    checkout develop
    commit id: "Update dependencies"

    branch feature/user-auth
    checkout feature/user-auth
    commit id: "Add JWT support"
    commit id: "Add password hashing"
    commit id: "Add login endpoint"

    branch feature/notifications
    checkout feature/notifications
    commit id: "Add email service"
    commit id: "Add notification queue"

    checkout develop
    merge feature/user-auth
    commit id: "Update docs"

    merge feature/notifications
    commit id: "Resolve conflicts"

    checkout main
    merge develop
    commit id: "v1.1.0 Release"
    commit id: "Bump version number"

    checkout develop
    commit id: "Prepare for v1.2"
```

**When to Use**:
- Documenting branching strategy
- Explaining Git workflows to team
- Planning release processes

---

## User Onboarding Journey

**Use Case**: SaaS product onboarding experience.

```mermaid
journey
    title SaaS Product Onboarding
    section Discovery
      Find product: 5: User
      Read landing page: 4: User, Marketing Site
      Check pricing: 3: User, Marketing Site
    section Signup
      Create account: 4: User, Signup Form
      Verify email: 3: User, Email Service
      Complete profile: 4: User, Signup Form
    section First Use
      View dashboard: 5: User, Application
      Create first project: 4: User, Application
      Invite team member: 3: User, Application
    section Engagement
      Configure settings: 3: User, Application
      Explore features: 5: User, Application
      Contact support: 2: User, Support Team
    section Conversion
      Start free trial: 5: User, Billing System
      Enter payment: 2: User, Payment Gateway
      Become paying customer: 5: User, Billing System
```

**When to Use**:
- Planning product onboarding
- Documenting user experience
- Identifying friction points

---

## Feature Dependency Graph

**Use Case**: Planning feature releases with dependencies.

```mermaid
graph TD
    A["Feature A<br/>Core API<br/>Status: In Progress"]
    B["Feature B<br/>Database<br/>Status: Blocked"]
    C["Feature C<br/>Authentication<br/>Status: Ready"]
    D["Feature D<br/>User Interface<br/>Status: Pending"]
    E["Feature E<br/>Integrations<br/>Status: Pending"]
    F["Feature F<br/>Admin Panel<br/>Status: Pending"]

    A --> B
    A --> D
    C --> D
    D --> E
    D --> F
    E --> F

    style A fill:#fff3e0
    style C fill:#e8f5e9
    style B fill:#ffebee
    style D fill:#e3f2fd
    style E fill:#e3f2fd
    style F fill:#e3f2fd

    classDef blocked fill:#ffebee,stroke:#c62828
    classDef inProgress fill:#fff3e0,stroke:#f57f17
    classDef ready fill:#e8f5e9,stroke:#2e7d32
    classDef pending fill:#e3f2fd,stroke:#1565c0
```

**When to Use**:
- Planning release schedules
- Identifying blockers
- Communicating dependencies

---

## Network Packet Structure

**Use Case**: IPv4 header format documentation.

```mermaid
packet-beta
    0-3: "Version"
    4-7: "Header Length"
    8-15: "Type of Service"
    16-31: "Total Length"

    32-47: "Identification"
    48-50: "Flags"
    51-63: "Fragment Offset"

    64-71: "TTL"
    72-79: "Protocol"
    80-95: "Header Checksum"

    96-127: "Source IP Address"
    128-159: "Destination IP Address"

    160-191: "Options"
```

**When to Use**:
- Documenting network protocols
- Teaching binary data structures
- Explaining packet formats

---

## Quick Reference by Use Case

| Use Case | Diagram Type | File |
|----------|-------------|------|
| Process workflows | Flowchart | `.mmd` |
| API interactions | Sequence Diagram | `.mmd` |
| Database schema | Entity Relationship | `.mmd` |
| State management | State Diagram | `.mmd` |
| Architecture overview | Graph/Flowchart | `.mmd` |
| Timeline planning | Gantt Chart | `.mmd` |
| Team responsibilities | Class Diagram | `.mmd` |
| System context | C4 Diagram | `.mmd` |
| Data distribution | Pie Chart | `.mmd` |
| Feature priority | Quadrant Chart | `.mmd` |
| Performance metrics | Radar Chart | `.mmd` |

