USE [master]
GO
/****** Object:  Database [bank]    Script Date: 01/06/2025 14:56:18 ******/
CREATE DATABASE [bank]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'bank', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.INSTANCE2022\MSSQL\DATA\bank.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'bank_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.INSTANCE2022\MSSQL\DATA\bank_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [bank] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [bank].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [bank] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [bank] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [bank] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [bank] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [bank] SET ARITHABORT OFF 
GO
ALTER DATABASE [bank] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [bank] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [bank] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [bank] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [bank] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [bank] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [bank] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [bank] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [bank] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [bank] SET  ENABLE_BROKER 
GO
ALTER DATABASE [bank] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [bank] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [bank] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [bank] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [bank] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [bank] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [bank] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [bank] SET RECOVERY FULL 
GO
ALTER DATABASE [bank] SET  MULTI_USER 
GO
ALTER DATABASE [bank] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [bank] SET DB_CHAINING OFF 
GO
ALTER DATABASE [bank] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [bank] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [bank] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [bank] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'bank', N'ON'
GO
ALTER DATABASE [bank] SET QUERY_STORE = ON
GO
ALTER DATABASE [bank] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [bank]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetAccountNetFlow]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetAccountNetFlow](@account_id CHAR(36))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @totalMasuk DECIMAL(18,2);
    DECLARE @totalKeluar DECIMAL(18,2);

    SELECT @totalMasuk = ISNULL(SUM(amount), 0)
    FROM transactions
    WHERE reference_account = @account_id;

    SELECT @totalKeluar = ISNULL(SUM(amount), 0)
    FROM transactions
    WHERE account_id = @account_id AND reference_account IS NOT NULL;

    RETURN @totalMasuk - @totalKeluar;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetActiveLoanCount]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetActiveLoanCount]()
RETURNS INT
AS
BEGIN
    DECLARE @activeLoanCount INT;

    SELECT @activeLoanCount = COUNT(*)
    FROM loans
    WHERE status = 'active';

    RETURN @activeLoanCount;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetCustomerFinancialSummary]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetCustomerFinancialSummary] (@customer_id CHAR(36))
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @total_balance DECIMAL(18, 2);
    DECLARE @total_loan DECIMAL(18, 2);
    DECLARE @result DECIMAL(18, 2);

    SELECT @total_balance = SUM(balance)
    FROM accounts
    WHERE customer_id = @customer_id;

    SELECT @total_loan = SUM(loan_amount)
    FROM loans
    WHERE customer_id = @customer_id;

    IF @total_balance IS NULL 
SET @total_balance = 0;
    IF @total_loan IS NULL 
SET @total_loan = 0;

    SET @result = @total_balance + @total_loan;
    RETURN @result;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetCustomerFullName]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetCustomerFullName] (@customer_id VARCHAR(36))
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE @full_name VARCHAR(255);

    SELECT @full_name = first_name + ' ' + last_name
    FROM customers
    WHERE customer_id = @customer_id;

    RETURN @full_name;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetTotalBalanceByCustomer]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetTotalBalanceByCustomer] (@customer_id CHAR (36))
RETURNS DECIMAL (10, 2)
AS
BEGIN
	DECLARE @total_balance DECIMAL (10, 2);
	SELECT @total_balance = SUM (balance)
	FROM accounts
	WHERE customer_id = @customer_id;

	IF @total_balance IS NULL
	BEGIN
		SET @total_balance = 0;
	END
	RETURN @total_balance;
END;
GO
/****** Object:  Table [dbo].[loans]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[loans](
	[loan_id] [char](36) NOT NULL,
	[customer_id] [char](36) NOT NULL,
	[loan_amount] [decimal](18, 2) NULL,
	[interest_rate] [decimal](5, 2) NULL,
	[loan_terms_months] [int] NULL,
	[start_date] [date] NULL,
	[end_date] [date] NULL,
	[status] [varchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_customer_loans_info]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_customer_loans_info]()
RETURNS TABLE
AS
RETURN
SELECT
    loan_id AS [Loan Id],
    loan_amount AS [Loan Amount],
    interest_rate AS [Interest Rate],
    loan_terms_months AS [Loan Terms (month)],
    start_date AS [Start Date],
    end_date AS [End Date],
    status AS [Status],
    DATEDIFF(DAY, GETDATE(), end_date) AS [Sisa Hari]
FROM
    loans;
GO
/****** Object:  Table [dbo].[transaction_types]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[transaction_types](
	[transaction_type_id] [int] NOT NULL,
	[name] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[transaction_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[transactions]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[transactions](
	[transaction_id] [char](36) NOT NULL,
	[account_id] [char](36) NOT NULL,
	[transaction_type_id] [int] NOT NULL,
	[amount] [decimal](18, 2) NULL,
	[transaction_date] [datetime] NULL,
	[description] [varchar](50) NULL,
	[reference_account] [char](36) NULL,
PRIMARY KEY CLUSTERED 
(
	[transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_transaction_counts_by_account]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_transaction_counts_by_account] AS
SELECT
    t.account_id,
    SUM(CASE WHEN tt.name = 'deposit' THEN 1 ELSE 0 END) AS deposit,
    SUM(CASE WHEN tt.name = 'transfer' THEN 1 ELSE 0 END) AS transfer,
    SUM(CASE WHEN tt.name = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal
FROM 
    transactions t
JOIN 
    transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
GROUP BY 
    t.account_id; 
GO
/****** Object:  View [dbo].[vw_recent_high_value_transactions]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_recent_high_value_transactions]  AS
SELECT * FROM transactions
WHERE
	transaction_date >= DATEADD(DAY, -30, GETDATE()) AND
	amount > (SELECT AVG(amount) FROM transactions);
GO
/****** Object:  Table [dbo].[customers]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customers](
	[customer_id] [char](36) NOT NULL,
	[first_name] [varchar](50) NULL,
	[last_name] [varchar](50) NULL,
	[email] [varchar](50) NULL,
	[phone_number] [varchar](20) NULL,
	[address] [varchar](255) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_customer_all]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_customer_all] AS
SELECT *
FROM customers;

GO
/****** Object:  View [dbo].[v_deposit_transaction]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_deposit_transaction] AS
SELECT t.*
FROM transactions t
JOIN transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.name = 'deposit';
GO
/****** Object:  View [dbo].[v_transfer_transaction]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_transfer_transaction] AS
SELECT t.*
FROM transactions t
JOIN transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.name = 'transfer';
GO
/****** Object:  Table [dbo].[accounts]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[accounts](
	[account_id] [char](36) NOT NULL,
	[customer_id] [char](36) NOT NULL,
	[account_number] [char](10) NULL,
	[account_type] [varchar](50) NOT NULL,
	[balance] [decimal](18, 2) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[account_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cards]    Script Date: 01/06/2025 14:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cards](
	[card_id] [char](36) NOT NULL,
	[account_id] [char](36) NOT NULL,
	[card_number] [varchar](30) NULL,
	[card_type] [varchar](25) NOT NULL,
	[expiration_date] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[card_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'07a36a4b-7943-4634-b17a-7c7eb4407cd3', N'287bf982-89ce-44b5-bfdd-49407600309a', N'8346813622', N'savings', CAST(8473.55 AS Decimal(18, 2)), CAST(N'2024-04-25T18:26:33.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'0937445f-d5eb-4ef9-887f-4173fe662dd4', N'b5c6a70e-f40c-43ac-9291-418539d54ae7', N'0925361770', N'credit', CAST(7739.25 AS Decimal(18, 2)), CAST(N'2024-04-25T16:46:18.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'1118a259-aa7d-402b-9f1f-72555ed15180', N'14f35ff7-5574-4e12-ad89-7e7704a02e62', N'7713339428', N'savings', CAST(11518.16 AS Decimal(18, 2)), CAST(N'2024-04-26T00:34:27.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'11d9d6f7-35d3-4ba3-bcca-a6b1e8f68519', N'33716558-b6fb-43ec-91a8-59207fe42376', N'4643651470', N'credit', CAST(9879.43 AS Decimal(18, 2)), CAST(N'2024-04-26T00:08:20.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'14f24b1b-6e86-4cb3-bbc4-0293bc90f756', N'23fd617f-9912-4a67-b5cb-60147b25930c', N'6037525484', N'credit', CAST(11555.86 AS Decimal(18, 2)), CAST(N'2024-04-25T17:48:49.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'15b082e5-92e7-4375-a7d9-f7224d35ba13', N'a34887df-cb28-4cab-a2ab-0f7de63719b9', N'2504168116', N'savings', CAST(9419.50 AS Decimal(18, 2)), CAST(N'2024-04-25T20:21:00.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'15c1de08-94a5-482d-9db5-682a1581ed84', N'43776145-9002-47aa-a868-c0ca95951f5b', N'6264480743', N'current', CAST(11309.22 AS Decimal(18, 2)), CAST(N'2024-04-26T01:31:27.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'17a9ed0a-5ed3-41d6-9e20-df434296c83d', N'ee6cebc9-6876-4561-9355-b84013639e66', N'1861310439', N'current', CAST(11644.05 AS Decimal(18, 2)), CAST(N'2024-04-25T22:18:31.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'1afc36b6-ae72-48ff-9d51-5f57fac653bc', N'd46ba1b1-9ff9-42e1-b7ad-7138cee43bf2', N'9736407913', N'credit', CAST(10013.89 AS Decimal(18, 2)), CAST(N'2024-04-25T23:12:26.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'1d97bce1-5c94-49e4-8e2a-6ad56b99afb0', N'69514bb4-0f65-4e74-b29e-92b1febb7933', N'9533820584', N'current', CAST(8003.75 AS Decimal(18, 2)), CAST(N'2024-04-25T21:34:26.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'2156bbb2-c082-45e5-a5d6-f66752c37690', N'6ca0328f-1be0-4205-9a57-59cef27a1067', N'9400361433', N'savings', CAST(9479.91 AS Decimal(18, 2)), CAST(N'2024-04-25T23:24:37.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'2229fe26-cc7f-4a58-9caf-d79a7f45b93e', N'b980c9fc-c205-4042-81ef-17a613787208', N'0531000214', N'current', CAST(9413.20 AS Decimal(18, 2)), CAST(N'2024-04-25T16:39:18.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'2b4fc68b-f926-4889-910b-634ad923efea', N'c7bb143b-430d-4bbc-9ab1-031826291851', N'3303452230', N'credit', CAST(11356.47 AS Decimal(18, 2)), CAST(N'2024-04-25T20:06:12.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'2fdf706a-7187-470c-a1c3-f3e747b72f20', N'6b7b3dfa-9959-401f-9b8c-fce6948abc45', N'8378959584', N'credit', CAST(7550.53 AS Decimal(18, 2)), CAST(N'2024-04-25T20:35:43.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'309d1066-7bcf-4772-9c5f-16aff605512e', N'f832a165-6ce7-4d54-9cf4-2b58ad4b4cf5', N'9913196358', N'current', CAST(9189.11 AS Decimal(18, 2)), CAST(N'2024-04-25T20:29:00.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'318c43bf-9511-4030-bd13-81a47a4b8cac', N'37abd855-71e9-4ded-87fe-901c4ccb3d3c', N'2528373607', N'credit', CAST(7854.32 AS Decimal(18, 2)), CAST(N'2024-04-25T22:53:45.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'34e9be76-4674-4d0f-b7c0-a39e43548747', N'85916c42-22cb-4462-9fa2-9c45feea827e', N'2187973070', N'credit', CAST(8590.58 AS Decimal(18, 2)), CAST(N'2024-04-26T01:37:44.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'36f3d280-2886-4e51-adcd-dfc644e59d80', N'1b056bda-e6c8-46bb-a706-8db8c2e53061', N'9387902534', N'savings', CAST(8374.51 AS Decimal(18, 2)), CAST(N'2024-04-25T18:58:59.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'39e495d4-8be7-45fa-aab6-1ee6312cdd04', N'9253d6d7-b356-4e9e-8fa4-e60c1d0327cc', N'1555272741', N'savings', CAST(9563.96 AS Decimal(18, 2)), CAST(N'2024-04-26T01:47:34.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'3a6e7b4a-c8db-4750-bbbc-a337ef92efe4', N'7f42152e-6a93-4d03-a9c9-ee0830c5096f', N'0080929534', N'savings', CAST(9364.19 AS Decimal(18, 2)), CAST(N'2024-04-25T21:57:50.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'3f494e04-a406-4692-a584-19db622e48ac', N'5c41586b-f7bf-41fa-883a-7b9cb1c4c849', N'4295222278', N'savings', CAST(11266.23 AS Decimal(18, 2)), CAST(N'2024-04-25T19:13:28.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'40ede99d-89ee-49c9-b1f9-de9b0e61ff33', N'e19d7be6-0155-4cb3-86ee-ba31a6ff5de1', N'2679408260', N'savings', CAST(10366.65 AS Decimal(18, 2)), CAST(N'2024-04-25T21:24:28.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'418a133e-5e1f-4377-8d48-63de24b5b08e', N'50acac78-1c19-491e-8e95-2787664d9090', N'2015740367', N'savings', CAST(8166.30 AS Decimal(18, 2)), CAST(N'2024-04-25T19:54:47.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'418fedb1-da8f-4c67-8073-4a147e2f5ded', N'5d8912f2-8074-4f41-b002-e0c789e7f718', N'9504378931', N'credit', CAST(7908.72 AS Decimal(18, 2)), CAST(N'2024-04-25T22:11:45.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'441aa9d2-bdf2-4b65-a79f-c18e66de0e17', N'f1082db9-8d80-4f63-9af8-db2ed4c41080', N'2552991115', N'credit', CAST(8548.32 AS Decimal(18, 2)), CAST(N'2024-04-25T18:51:48.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'45d4aa3e-cee4-431f-ac63-f83e4c56e862', N'a23ae674-314f-4a4b-845a-ae0ff78d3512', N'2457207788', N'current', CAST(9583.76 AS Decimal(18, 2)), CAST(N'2024-04-26T01:50:45.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'45ff6d75-3e4b-43ab-9343-ba2e0de1069a', N'1f2aa50e-b682-43da-b36e-f33d041691dc', N'8125017439', N'credit', CAST(9791.44 AS Decimal(18, 2)), CAST(N'2024-04-25T18:18:15.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'48eef121-050c-4362-b2b1-96a32f5fe6a9', N'4a150c66-0c2b-4626-8e66-4035a87c1ab0', N'8992271456', N'credit', CAST(7548.97 AS Decimal(18, 2)), CAST(N'2024-04-25T17:22:01.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'4aab87c4-eb74-4e4e-ab8f-c13638276de1', N'ba054855-8fa2-4f85-965a-6ba3b5fc13d3', N'0829651833', N'current', CAST(12152.62 AS Decimal(18, 2)), CAST(N'2024-04-25T19:22:24.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'4adb1b7b-163e-4a1b-956f-9a3fa65d8b70', N'43803350-bfb2-46b7-8949-24dc4b72fbf3', N'6990994811', N'credit', CAST(12170.02 AS Decimal(18, 2)), CAST(N'2024-04-26T01:02:59.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'4d499ecc-5bee-4104-a1b0-32ceff979305', N'a424f2b5-0890-4fc1-a71e-9ea7547a5a25', N'2978718771', N'savings', CAST(9948.52 AS Decimal(18, 2)), CAST(N'2024-04-25T22:43:49.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'4fae08d1-3301-4031-a7d5-1b6eac9a2bdd', N'3f5ab011-f526-4bbd-8ab8-8a67ad95c5bf', N'1685828176', N'credit', CAST(9635.80 AS Decimal(18, 2)), CAST(N'2024-04-25T16:04:13.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'535ff8ea-7b01-48a3-93a3-27288067830c', N'a9de1fc5-3ba9-4088-8ee6-5a75104f2c7d', N'5502821697', N'current', CAST(10851.95 AS Decimal(18, 2)), CAST(N'2024-04-25T18:10:33.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'54c49a0b-5dc6-46f8-abf2-ed2d1e56da8c', N'1f72084e-90f3-4334-9b8f-a3b350c2beb0', N'4885167114', N'current', CAST(9788.96 AS Decimal(18, 2)), CAST(N'2024-04-25T23:03:15.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'57620a31-a1ee-4dbc-9a72-09bc5bb72b7d', N'3eec958e-8cd8-426e-8603-eac1c9b2c004', N'5606148528', N'savings', CAST(9089.69 AS Decimal(18, 2)), CAST(N'2024-04-25T21:47:17.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'58e3e8fa-7549-4390-821e-d643a13d9c36', N'ea53056c-33eb-49f9-b00d-71b8b74f5829', N'9726970308', N'savings', CAST(10054.09 AS Decimal(18, 2)), CAST(N'2024-04-25T17:23:40.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'5b98a4b0-ee51-4b17-9584-d5ae35ce9e6b', N'fd29af21-54cd-42a1-a4d7-40890f6dd658', N'5252342645', N'savings', CAST(12491.78 AS Decimal(18, 2)), CAST(N'2024-04-25T20:10:22.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'5ccb459e-6c87-432b-a742-c6c7cbf0dae3', N'ed4658f1-c11e-484a-b761-c911885548c2', N'8493110781', N'credit', CAST(11681.49 AS Decimal(18, 2)), CAST(N'2024-04-25T16:06:08.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'5d8f91d2-881d-46c9-9d1f-19d33516897f', N'26ae893b-6b51-41b9-9b07-a8d07e8a2979', N'3578650352', N'credit', CAST(9901.20 AS Decimal(18, 2)), CAST(N'2024-04-26T00:42:54.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'5ea6c838-111c-484c-9b2b-bc4b5776f48f', N'6f6a46c1-26ae-47c8-82aa-34027c84af78', N'5771758571', N'credit', CAST(11976.35 AS Decimal(18, 2)), CAST(N'2024-04-25T22:37:23.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'65b4514d-4bbb-4aed-b0e0-859e1bef135e', N'0bedb8d0-0c5a-48a9-bae1-5b1fbecf4a10', N'0851676096', N'credit', CAST(9900.74 AS Decimal(18, 2)), CAST(N'2024-04-25T17:43:38.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'68c0a815-9332-4453-8a91-5ce066bb07e2', N'9f2f61c6-ee32-4494-85a3-2425d533a5b8', N'9084279295', N'current', CAST(11201.80 AS Decimal(18, 2)), CAST(N'2024-04-25T20:13:32.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'6d17ee21-72d5-4fb5-a638-ef220307dcd9', N'6e360958-11c9-41fc-a89f-4238b8a0ae24', N'1588301119', N'savings', CAST(8549.18 AS Decimal(18, 2)), CAST(N'2024-04-25T23:57:37.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'6edc13ce-6ed2-48a7-b73d-ef6ed8b73e38', N'ef255303-e28b-4229-aa6f-99eb4f67a81c', N'5227798778', N'credit', CAST(9827.91 AS Decimal(18, 2)), CAST(N'2024-04-25T18:27:37.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'70b25eda-9b65-489a-b3b5-1b7650795fbd', N'870ae237-d669-42dd-b283-99c1219bf349', N'4123981372', N'current', CAST(10811.93 AS Decimal(18, 2)), CAST(N'2024-04-25T22:02:18.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'71c0f7ab-b701-45f0-9c94-802383b3cc36', N'3a57a285-56e7-4900-bc63-d044f2247ff1', N'4439138749', N'credit', CAST(12301.00 AS Decimal(18, 2)), CAST(N'2024-04-25T17:06:17.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'71de6c84-d689-4792-b730-7711deb2a408', N'b3e475f6-203f-474f-a30c-243fe885b3e1', N'6496171469', N'current', CAST(9467.68 AS Decimal(18, 2)), CAST(N'2024-04-25T23:09:43.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'72acc609-0cc6-4fcd-bad7-5d7e6c58ae3d', N'b4a5aa8b-b1f2-478d-b60c-7efd3b198ee5', N'2944854389', N'credit', CAST(10805.82 AS Decimal(18, 2)), CAST(N'2024-04-25T23:44:10.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'73b13073-025d-45c9-bed2-6b6760e7e10d', N'93718b0c-9337-4efa-bd48-51713fb1523c', N'1656200086', N'current', CAST(8837.70 AS Decimal(18, 2)), CAST(N'2024-04-25T18:37:30.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'748ace76-6b8a-4fd4-9de1-b6154ce22189', N'9e5061d8-a27f-44cc-a390-5f9ab4d00178', N'3556624060', N'current', CAST(9763.55 AS Decimal(18, 2)), CAST(N'2024-04-25T16:56:45.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'789de9f0-5ef0-46cc-bb19-fbe4928474e6', N'abd49d49-237d-4d28-b3ea-9d19661fcf9b', N'7404474193', N'current', CAST(10950.41 AS Decimal(18, 2)), CAST(N'2024-04-25T20:03:18.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'7b1fccd6-d4ab-4f58-9ae1-b45947264b33', N'61ac2df4-4e87-4f00-af98-a9c55edbdd80', N'0690581077', N'credit', CAST(11177.27 AS Decimal(18, 2)), CAST(N'2024-04-25T20:49:34.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'802b2efe-e1d1-465b-940f-5cf573a2c985', N'3701903e-265f-402d-b8f9-5e46a67a89a6', N'1704735459', N'credit', CAST(11396.93 AS Decimal(18, 2)), CAST(N'2024-04-26T00:51:57.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'80c28cdf-f2fb-4232-bbd5-39404d8199c2', N'a99c66ac-ae2a-4375-b15c-9b1694200e6d', N'9060219682', N'current', CAST(11425.85 AS Decimal(18, 2)), CAST(N'2024-04-25T19:40:47.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'80d384e7-9b48-4806-9897-32969e337683', N'7ab376ee-2fca-4f08-98aa-9b93cc0fc972', N'0130433753', N'savings', CAST(11086.68 AS Decimal(18, 2)), CAST(N'2024-04-26T00:14:48.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'85202b58-ec17-4407-ae0b-fab4ae861dac', N'52d177ad-467a-400c-9f5e-a51bfffce616', N'1474276485', N'current', CAST(9143.14 AS Decimal(18, 2)), CAST(N'2024-04-26T00:03:15.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'89a22c8c-57ba-4baa-8b71-13d1210a62d6', N'cd125a77-15a1-4c04-aaed-41a05195225b', N'1826894165', N'credit', CAST(10483.59 AS Decimal(18, 2)), CAST(N'2024-04-25T22:20:08.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'8a54f7b6-3ac0-4aee-88c4-ff386444e673', N'29f948c1-0d27-4e13-9126-498a6e51a079', N'2655293508', N'savings', CAST(7557.60 AS Decimal(18, 2)), CAST(N'2024-04-25T16:12:40.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'8c46fae1-9789-4427-8440-7cf48a0272cd', N'5b3fb023-fd43-4cae-8783-ef1c98d11b38', N'9936621019', N'credit', CAST(9768.42 AS Decimal(18, 2)), CAST(N'2024-04-25T16:20:15.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'8d7d7e4b-11a9-47e3-bca0-8f3aa0bada73', N'53a68a7b-f69c-4a25-8846-0f06497a3b6d', N'8952674354', N'credit', CAST(9702.38 AS Decimal(18, 2)), CAST(N'2024-04-25T23:35:49.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'8d8d1450-995a-4db8-84d1-47779bd7d233', N'82cac284-ec70-4be8-a43e-b002fc419e26', N'8375062940', N'savings', CAST(8034.65 AS Decimal(18, 2)), CAST(N'2024-04-25T17:28:48.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'905660c8-d6a7-40e9-9be3-e6711d22efb6', N'f8628b73-c900-4973-849e-22aa8e42fc33', N'5421050024', N'current', CAST(8818.69 AS Decimal(18, 2)), CAST(N'2024-04-25T15:54:41.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'916673e7-fd52-47ed-bece-efb700890f1f', N'79dcf8ce-329d-48a8-ac2c-9fa869b4ac42', N'2529864614', N'current', CAST(11890.48 AS Decimal(18, 2)), CAST(N'2024-04-25T16:50:00.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'92ffabae-dab4-4737-8b26-ee60ed598cea', N'daf898aa-13cd-465a-b2ed-ce3605ff9cc2', N'4154417169', N'credit', CAST(10871.11 AS Decimal(18, 2)), CAST(N'2024-04-26T00:25:34.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'96da7988-0695-4780-a7c3-6c935daccc59', N'462d21d0-7672-428a-abf7-04c18a1efde8', N'4896256429', N'current', CAST(11370.14 AS Decimal(18, 2)), CAST(N'2024-04-26T00:19:28.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'980c1a90-3d66-4010-81c8-32cde239d423', N'c7a3c75f-3b79-4fdb-a4ab-52a54401b875', N'3853720021', N'current', CAST(11987.17 AS Decimal(18, 2)), CAST(N'2024-04-26T01:22:26.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'9cd97ecb-58c9-4610-b4b1-d9f72bcae7f7', N'1ea5ec60-3f36-4896-af24-13ee03bf06d9', N'9885390599', N'savings', CAST(9038.34 AS Decimal(18, 2)), CAST(N'2024-04-25T15:51:30.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'a2ab1bd6-0020-4555-ba43-5c1f69332851', N'86f4ec23-7064-4bb5-9aaf-b8e98e8d95ec', N'9760233499', N'savings', CAST(10416.31 AS Decimal(18, 2)), CAST(N'2024-04-25T23:16:50.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'a448f319-9dc4-4c02-b016-e1eab2b49629', N'ef998517-9d3b-429c-be1b-5b164ba2afe2', N'6580443064', N'current', CAST(11362.38 AS Decimal(18, 2)), CAST(N'2024-04-25T21:52:50.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'a6d46634-1645-4107-8594-983d4a4c90ce', N'8e07d624-a56d-4734-a552-2b3985adedbd', N'7474814784', N'credit', CAST(10225.06 AS Decimal(18, 2)), CAST(N'2024-04-25T19:49:04.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'a9eb22fe-d2a1-4f58-b903-ba06bfab92c4', N'bb09df35-4fb6-42be-a106-f0f1f1a74012', N'0732497685', N'savings', CAST(7966.49 AS Decimal(18, 2)), CAST(N'2024-04-25T22:25:41.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'ac35eddd-0fb1-4711-9bb8-1985fc566b52', N'27693ec7-45c9-4230-89d2-d0c98654cde7', N'1582257006', N'savings', CAST(11847.59 AS Decimal(18, 2)), CAST(N'2024-04-25T21:08:26.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'b28eca06-abd3-43b5-b602-37bca09a6116', N'57829c08-247e-4dec-b528-cd1099fc1e81', N'7240585472', N'current', CAST(9471.21 AS Decimal(18, 2)), CAST(N'2024-04-25T18:05:02.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'b2b1797e-b848-4af5-8a52-2e4d66a5af90', N'1833e0d4-fd6c-4474-b416-3ce9e539b363', N'6958155556', N'current', CAST(10283.46 AS Decimal(18, 2)), CAST(N'2024-04-25T20:42:17.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'bc45041a-05a7-4c9e-a2c0-324829aaca62', N'6a9b75fb-c1c5-4e1a-a94e-07cbb5c41837', N'8102086547', N'savings', CAST(9980.78 AS Decimal(18, 2)), CAST(N'2024-04-25T23:48:39.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'be1f9370-375a-4d20-bf0d-284e833ff113', N'6b612ed4-f731-4963-85f3-780a438e0fad', N'8526139668', N'current', CAST(11213.28 AS Decimal(18, 2)), CAST(N'2024-04-25T22:35:13.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'bf4afaa6-c52c-4b4e-b7f8-543eeb1ec49c', N'7f18c59c-3e61-43f6-946f-d0b81fbd3cc7', N'6417382807', N'savings', CAST(10455.22 AS Decimal(18, 2)), CAST(N'2024-04-25T20:55:32.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'bff8f8bd-3931-4f3f-b0c1-636597f97db5', N'585b6bfa-e33a-4e75-8d2e-5cf1e4a42197', N'4448148587', N'current', CAST(8568.36 AS Decimal(18, 2)), CAST(N'2024-04-25T21:11:02.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'c044b4de-6caf-4d33-91d3-50c621e194b0', N'fa5b05d5-cd6d-4e43-840d-4e368a1dac48', N'2273497539', N'current', CAST(8225.68 AS Decimal(18, 2)), CAST(N'2024-04-25T23:29:49.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'c098f0dd-6434-4f69-afdd-d756849fe1fd', N'13aac759-5c49-42dc-9693-0f46cb1337bb', N'8421559542', N'savings', CAST(7757.62 AS Decimal(18, 2)), CAST(N'2024-04-26T01:12:55.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'C3421FAA-2BB6-4BE5-875A-2234221C42B0', N'9d78736f-df51-4622-9cb1-c4db88dca2d0', N'2075461919', N'current', CAST(10838.30 AS Decimal(18, 2)), CAST(N'2025-05-05T20:28:52.923' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'c49c54f1-1926-4cbb-b3f2-2299152dce3a', N'20b542e7-3b96-4059-b30a-6d09832e17de', N'2537086085', N'savings', CAST(11935.55 AS Decimal(18, 2)), CAST(N'2024-04-26T01:00:52.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'c4dd8020-5b57-4739-9d49-0f7172ffaf3f', N'db0df896-914e-491f-9e31-454b9f1d3c7f', N'8771754618', N'savings', CAST(8145.11 AS Decimal(18, 2)), CAST(N'2024-04-25T17:57:04.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'c50f01a9-441b-4a71-81c8-9f2a78288a92', N'0ca06e8d-a7a2-40c4-893b-128336ffdf54', N'8530330039', N'current', CAST(10980.79 AS Decimal(18, 2)), CAST(N'2024-04-26T00:49:49.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'c73f146f-aef6-415f-bc17-8bf06ba9819e', N'b9779359-2984-4b3a-83cd-0e0eab80293c', N'2769479719', N'current', CAST(9708.94 AS Decimal(18, 2)), CAST(N'2024-04-26T00:36:55.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'c8a710b1-6302-4189-8149-da76be7fdfc1', N'e8a917b4-9641-4271-91a2-2a0ef3477c76', N'0327410016', N'savings', CAST(9149.16 AS Decimal(18, 2)), CAST(N'2024-04-25T19:32:06.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'ca19992d-7bc5-4903-8fba-699825411b95', N'719c88a7-ba09-4109-a4f8-ba659d01ebf6', N'6182594105', N'credit', CAST(11883.99 AS Decimal(18, 2)), CAST(N'2024-04-25T19:41:57.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'ce49f4c7-302b-4d63-b068-8f01fd6e28a7', N'6daa0a7c-3ca5-4ace-9d6c-b119d9067a6a', N'9293350610', N'savings', CAST(11102.62 AS Decimal(18, 2)), CAST(N'2024-04-25T18:31:30.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'd094e634-9744-478d-b73b-1a73149b198b', N'9da1cc29-9c8b-498c-bbbd-c412a8115cc8', N'9454584737', N'current', CAST(11920.21 AS Decimal(18, 2)), CAST(N'2024-04-25T18:42:53.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'd29c5b3d-6bb3-4248-bf1a-4339bc80b6b0', N'9d78736f-df51-4622-9cb1-c4db88dca2d0', N'2075461919', N'current', CAST(10838.30 AS Decimal(18, 2)), CAST(N'2024-04-25T23:51:31.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'd6a1328a-055b-40f3-9c71-da27fec396d2', N'ed5f70a9-36e5-433b-abbc-fed08b27bb16', N'0062060878', N'savings', CAST(10699.44 AS Decimal(18, 2)), CAST(N'2024-04-25T16:48:48.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'd7461fd9-005f-47c5-aed6-98c6b03f378b', N'f023ea3c-6500-4297-868e-abd3043b97c1', N'1204062801', N'credit', CAST(8127.95 AS Decimal(18, 2)), CAST(N'2024-04-25T21:17:02.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'da3b43bc-55d1-4f0b-80d1-494ccfc9acc5', N'd01d990c-8cbd-4b0f-87b3-4c31fafbf3d5', N'0587333038', N'savings', CAST(10257.16 AS Decimal(18, 2)), CAST(N'2024-04-25T17:07:39.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'def2f626-6db4-4fea-baa2-33fafd90c494', N'd933fcc1-a91f-4051-9cc1-58e1bf6be236', N'8786190425', N'credit', CAST(12405.09 AS Decimal(18, 2)), CAST(N'2024-04-25T21:41:24.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'dfd76a72-6dbc-4b94-a856-b77dd59d3b4a', N'357e3969-87b3-48e9-bd0b-4a658de0dd38', N'5823994373', N'credit', CAST(9504.70 AS Decimal(18, 2)), CAST(N'2024-04-25T20:59:27.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'e0c672fd-8182-42b1-8a70-2138f223c47c', N'623e0b78-6b7c-4e98-a46a-c96d1c607817', N'0500742994', N'current', CAST(11273.06 AS Decimal(18, 2)), CAST(N'2024-04-25T16:16:29.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'eae2bb46-3bd9-4bd6-a6b7-1b2efdc1911a', N'4837eb17-36bb-4c4b-bb49-bc368edb173a', N'8822070016', N'savings', CAST(11333.82 AS Decimal(18, 2)), CAST(N'2024-04-25T22:56:01.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'ed508747-a9a1-432c-980f-388a4be8398d', N'dc0f5f48-84ef-4f9b-bd05-ef9217f050fe', N'9861896539', N'credit', CAST(11060.36 AS Decimal(18, 2)), CAST(N'2024-04-25T19:04:24.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'f75c87e7-70a8-4fbd-8ad6-9d5e9cefc314', N'079cd6ce-04a8-4c55-8c2b-b93189e9050a', N'3849055069', N'current', CAST(12498.44 AS Decimal(18, 2)), CAST(N'2024-04-25T17:12:29.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'f9341b55-2686-40af-9e1b-2986672efd92', N'6ae55628-7994-4e93-b964-f75e00363d72', N'3493783953', N'current', CAST(9418.54 AS Decimal(18, 2)), CAST(N'2024-04-25T17:37:38.000' AS DateTime))
GO
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'fe716f26-3b0e-4fe5-bc40-4663f4fa66c0', N'f40f3b32-6b03-4f88-896a-949bb777a247', N'7644255747', N'savings', CAST(9900.74 AS Decimal(18, 2)), CAST(N'2024-04-25T16:29:20.000' AS DateTime))
INSERT [dbo].[accounts] ([account_id], [customer_id], [account_number], [account_type], [balance], [created_at]) VALUES (N'new-account-id-1                    ', N'1ea5ec60-3f36-4896-af24-13ee03bf06d9', N'9999999999', N'savings', CAST(1000.00 AS Decimal(18, 2)), CAST(N'2025-05-22T15:02:31.617' AS DateTime))
GO
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'0277daeb-c77d-43b0-b049-33bc7d024744', N'802b2efe-e1d1-465b-940f-5cf573a2c985', N'4830343622653949', N'debit', CAST(N'2024-07-17' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'02e348c7-a8ff-43bc-861c-a54b2ed3febc', N'980c1a90-3d66-4010-81c8-32cde239d423', N'617416399548004592', N'credit', CAST(N'2024-08-19' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'04e5672b-6b20-4cb4-85c9-93a7f2ed7d28', N'72acc609-0cc6-4fcd-bad7-5d7e6c58ae3d', N'341081612406547', N'credit', CAST(N'2025-01-23' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'062241fe-b20b-4507-8037-5cc2f55159be', N'3a6e7b4a-c8db-4750-bbbc-a337ef92efe4', N'345181959052601', N'credit', CAST(N'2024-08-23' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'06267414-602e-4364-829d-74718b3b42d8', N'418fedb1-da8f-4c67-8073-4a147e2f5ded', N'374808404066892', N'debit', CAST(N'2024-12-07' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'07fa4f57-a214-4e56-8076-40a380ce2335', N'8a54f7b6-3ac0-4aee-88c4-ff386444e673', N'377042735626230', N'debit', CAST(N'2024-05-13' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'08414549-8847-4682-8589-0b7ad5dccba8', N'2156bbb2-c082-45e5-a5d6-f66752c37690', N'377145743442232', N'debit', CAST(N'2025-02-07' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'12f61a47-ed35-4064-9b34-76d3b9a1350e', N'11d9d6f7-35d3-4ba3-bcca-a6b1e8f68519', N'610258712558331588', N'debit', CAST(N'2024-10-27' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'1450f131-4b66-45ac-a676-580b9a9d7dba', N'48eef121-050c-4362-b2b1-96a32f5fe6a9', N'5265655805574571', N'debit', CAST(N'2024-05-25' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'147d1847-cb22-4b98-ba2c-fb47249ffaaf', N'2fdf706a-7187-470c-a1c3-f3e747b72f20', N'602147091328309303', N'credit', CAST(N'2025-01-28' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'14db8f87-67bb-4a67-b0cb-9bcd7209960e', N'441aa9d2-bdf2-4b65-a79f-c18e66de0e17', N'372763304326682', N'debit', CAST(N'2025-02-10' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'160e32ee-db6f-4605-a947-897ca22bbc20', N'6d17ee21-72d5-4fb5-a638-ef220307dcd9', N'348411742003251', N'debit', CAST(N'2024-06-08' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'17e2d5a8-5b0f-4bc5-88f1-a27a16345066', N'a6d46634-1645-4107-8594-983d4a4c90ce', N'4112003708395083', N'debit', CAST(N'2024-06-03' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'1c7e9cc4-eec0-442b-9e47-8a85333f6c42', N'd29c5b3d-6bb3-4248-bf1a-4339bc80b6b0', N'345018917841588', N'credit', CAST(N'2024-06-14' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'239cb94e-64ed-4313-884b-e6171884f571', N'7b1fccd6-d4ab-4f58-9ae1-b45947264b33', N'371028167021611', N'credit', CAST(N'2024-09-09' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'24c2254c-8569-474f-bdb6-f2238c7cf4a3', N'bff8f8bd-3931-4f3f-b0c1-636597f97db5', N'5490977694077285', N'credit', CAST(N'2024-10-25' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'26f77805-db60-4c27-b10f-b3297deb4d9e', N'1afc36b6-ae72-48ff-9d51-5f57fac653bc', N'5359336569985918', N'debit', CAST(N'2024-08-26' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'2d50984d-8c80-4d31-b838-3ef6ed47059b', N'f75c87e7-70a8-4fbd-8ad6-9d5e9cefc314', N'346265634959371', N'credit', CAST(N'2025-01-12' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'2ff41b50-b145-498e-8cd9-9407505d170c', N'3f494e04-a406-4692-a584-19db622e48ac', N'349838650679207', N'credit', CAST(N'2024-11-26' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'30da5816-fbe5-44fc-8e2a-c2f6f0ea3be2', N'5ccb459e-6c87-432b-a742-c6c7cbf0dae3', N'4751653597240', N'credit', CAST(N'2024-12-30' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'33237613-3a17-4101-b24e-b73fa2245c21', N'58e3e8fa-7549-4390-821e-d643a13d9c36', N'4196693533459515', N'credit', CAST(N'2024-12-14' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'39985b54-0c1d-482a-8c27-dbc0c930ca4f', N'd6a1328a-055b-40f3-9c71-da27fec396d2', N'4680988449029284', N'credit', CAST(N'2024-05-03' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'3b51f117-1adf-4c68-83ed-0542eaf787ce', N'da3b43bc-55d1-4f0b-80d1-494ccfc9acc5', N'342828062307774', N'credit', CAST(N'2025-02-23' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'3c77d4e2-98a3-406d-96d1-6f6edbf56dc3', N'39e495d4-8be7-45fa-aab6-1ee6312cdd04', N'4779591067125', N'debit', CAST(N'2025-03-11' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'3d268772-9e67-431e-9c22-e57ef6eef9da', N'b28eca06-abd3-43b5-b602-37bca09a6116', N'5495193987832569', N'debit', CAST(N'2025-02-19' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'3d32a92a-c899-42b1-9567-39b4ace56c31', N'916673e7-fd52-47ed-bece-efb700890f1f', N'4179411186310500', N'debit', CAST(N'2025-02-11' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'425afc90-2fcc-4040-bbaf-db4ea5176a5f', N'fe716f26-3b0e-4fe5-bc40-4663f4fa66c0', N'602569807950146963', N'debit', CAST(N'2024-09-14' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'45ad4a5c-fc29-4ef3-9f04-ebaf927b9e9e', N'36f3d280-2886-4e51-adcd-dfc644e59d80', N'5247195743755274', N'credit', CAST(N'2025-04-16' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'469e9231-a6a0-4acf-b769-b3887d5956f8', N'40ede99d-89ee-49c9-b1f9-de9b0e61ff33', N'349733003251728', N'debit', CAST(N'2025-01-02' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'476c59b3-64b7-422e-a9fc-5e216a77160f', N'd094e634-9744-478d-b73b-1a73149b198b', N'610998337426400244', N'debit', CAST(N'2024-12-31' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'4d6e3545-7a8d-4853-acad-57995e2e9a05', N'f9341b55-2686-40af-9e1b-2986672efd92', N'4710923681866741', N'debit', CAST(N'2024-05-12' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'4d86e2b7-7f8d-4d4a-9622-84d695073a1c', N'4d499ecc-5bee-4104-a1b0-32ceff979305', N'612903224143401111', N'debit', CAST(N'2024-07-29' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'50b69b55-9cb7-4563-a2d3-ba39042c84b1', N'bc45041a-05a7-4c9e-a2c0-324829aaca62', N'4816715287749351', N'debit', CAST(N'2024-08-28' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'50d93376-a313-40dd-af52-91842a96f8b8', N'34e9be76-4674-4d0f-b7c0-a39e43548747', N'375638079726753', N'credit', CAST(N'2025-04-23' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'5324a2af-f332-4d42-9581-3e9212ce902b', N'c8a710b1-6302-4189-8149-da76be7fdfc1', N'5427163849475421', N'debit', CAST(N'2024-11-27' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'53aa254b-1c5d-473d-a5b8-c8db623a9e87', N'c044b4de-6caf-4d33-91d3-50c621e194b0', N'4253532082189968', N'debit', CAST(N'2025-03-26' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'5449db2a-73d8-45d3-b555-774e789374d0', N'5d8f91d2-881d-46c9-9d1f-19d33516897f', N'600013816243877587', N'credit', CAST(N'2025-04-22' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'5955a1b7-52d2-49be-b344-1b9faaf24c1a', N'14f24b1b-6e86-4cb3-bbc4-0293bc90f756', N'610055020487163113', N'credit', CAST(N'2024-11-28' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'59e11ab2-8545-4004-aa8c-193c149495f2', N'def2f626-6db4-4fea-baa2-33fafd90c494', N'613084037991179368', N'credit', CAST(N'2024-06-06' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'5b856b8c-79b3-4c62-8657-c2a20512c2e7', N'45ff6d75-3e4b-43ab-9343-ba2e0de1069a', N'609841610428309592', N'credit', CAST(N'2025-02-05' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'5cae8bc9-2cba-49df-82f8-6c9851d3f00f', N'80c28cdf-f2fb-4232-bbd5-39404d8199c2', N'603198736992399776', N'credit', CAST(N'2024-09-20' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'5d97e252-ab32-4f18-a763-b3b0332d3bfa', N'57620a31-a1ee-4dbc-9a72-09bc5bb72b7d', N'608459762865241328', N'credit', CAST(N'2024-11-15' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'5f9a6528-b435-4625-8878-f0244607c005', N'c49c54f1-1926-4cbb-b3f2-2299152dce3a', N'5476348265610219', N'debit', CAST(N'2024-12-07' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'63690f6b-534c-4622-aae3-0ee7c6b6c650', N'89a22c8c-57ba-4baa-8b71-13d1210a62d6', N'4383963440809', N'credit', CAST(N'2025-02-05' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'6b4056b7-2154-4f7a-9fc0-45beb63c5611', N'ac35eddd-0fb1-4711-9bb8-1985fc566b52', N'5192945646404106', N'credit', CAST(N'2024-10-29' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'6b80bef7-3696-44af-85c4-3e3b7de915d6', N'0937445f-d5eb-4ef9-887f-4173fe662dd4', N'611096215899557980', N'debit', CAST(N'2025-03-02' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'6cae210f-0ad9-4f6d-9453-36eaeb99d8d9', N'70b25eda-9b65-489a-b3b5-1b7650795fbd', N'370953767850143', N'debit', CAST(N'2024-06-11' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'6dd443f6-76fd-4ebc-a158-ea8ffa06c695', N'b2b1797e-b848-4af5-8a52-2e4d66a5af90', N'610409547084913527', N'debit', CAST(N'2025-01-02' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'70d99330-4658-4e5a-8272-8cdc0f81df48', N'748ace76-6b8a-4fd4-9de1-b6154ce22189', N'5455430022628083', N'debit', CAST(N'2025-04-08' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'74a8f0ba-ebb9-4a69-a721-9f09fc78e339', N'6edc13ce-6ed2-48a7-b73d-ef6ed8b73e38', N'5398657954290850', N'debit', CAST(N'2024-08-05' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'75a14e25-794a-458d-a9f7-f2fc9fde5f3f', N'96da7988-0695-4780-a7c3-6c935daccc59', N'608674252647852112', N'debit', CAST(N'2024-05-01' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'76d7dd79-f2a1-4285-9048-5bddcf8c51b7', N'2b4fc68b-f926-4889-910b-634ad923efea', N'4955583745547', N'debit', CAST(N'2024-10-17' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'7770caab-3418-43ed-bec6-b8963092dbb8', N'80d384e7-9b48-4806-9897-32969e337683', N'5366716010905675', N'debit', CAST(N'2024-06-12' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'79dc06b0-9924-4c42-b4ad-3731104a2ea5', N'ce49f4c7-302b-4d63-b068-8f01fd6e28a7', N'375505919407603', N'credit', CAST(N'2024-05-30' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'7a134652-1491-4fbd-adee-4500a2b57bfa', N'd7461fd9-005f-47c5-aed6-98c6b03f378b', N'616851652320789903', N'debit', CAST(N'2025-04-08' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'7ba1d153-ec28-42fb-bd39-830deb48582b', N'4fae08d1-3301-4031-a7d5-1b6eac9a2bdd', N'616720099071012755', N'credit', CAST(N'2024-11-13' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'7bdc64a7-52b1-4de9-b781-7019aaebafc3', N'c73f146f-aef6-415f-bc17-8bf06ba9819e', N'612475276939830752', N'debit', CAST(N'2024-09-26' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'7f6d2495-9221-4531-bd8f-00590beede5c', N'a9eb22fe-d2a1-4f58-b903-ba06bfab92c4', N'617975596867923293', N'debit', CAST(N'2025-02-27' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'8292fe26-3515-46b7-8be0-bd355acd5af2', N'15b082e5-92e7-4375-a7d9-f7224d35ba13', N'379063365347635', N'credit', CAST(N'2024-12-04' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'85a01d94-85dc-4e23-9f6a-d39cc1b702da', N'45d4aa3e-cee4-431f-ac63-f83e4c56e862', N'5278752967165796', N'debit', CAST(N'2024-05-02' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'88e41144-3082-457c-8370-ba5f7199af70', N'8d8d1450-995a-4db8-84d1-47779bd7d233', N'348216935143384', N'debit', CAST(N'2024-09-07' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'8b420a1b-186a-4ecf-ac94-06dbe721e7b0', N'a2ab1bd6-0020-4555-ba43-5c1f69332851', N'5435231708290932', N'debit', CAST(N'2025-02-01' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'8be0670c-ce06-4913-a20f-1b6fc0c6b838', N'73b13073-025d-45c9-bed2-6b6760e7e10d', N'611240813877102178', N'credit', CAST(N'2025-04-26' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'913da6c2-3a88-4a9e-810b-2fb3810563d7', N'4adb1b7b-163e-4a1b-956f-9a3fa65d8b70', N'4609562070650672', N'credit', CAST(N'2024-07-21' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'99d95af1-b076-4856-a097-c65d187aaa49', N'535ff8ea-7b01-48a3-93a3-27288067830c', N'5372926409487829', N'credit', CAST(N'2024-06-14' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'9aae5de0-948f-4afb-82c2-614b11764e93', N'ed508747-a9a1-432c-980f-388a4be8398d', N'5238920802734873', N'credit', CAST(N'2025-02-15' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'9ad19f3e-d586-41df-9ed9-ae5ed8abe1c2', N'15c1de08-94a5-482d-9db5-682a1581ed84', N'4010250561404', N'debit', CAST(N'2024-08-06' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'9b279402-7912-40a7-8d7d-34d4bb9290ad', N'be1f9370-375a-4d20-bf0d-284e833ff113', N'373584511303960', N'debit', CAST(N'2024-11-17' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'9d116062-58ae-42a9-aaab-ea3619c1f3a4', N'68c0a815-9332-4453-8a91-5ce066bb07e2', N'609261895801879342', N'debit', CAST(N'2024-07-30' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'a0221c84-54ae-4fba-b3c1-9198878ba950', N'8c46fae1-9789-4427-8440-7cf48a0272cd', N'349563186046762', N'debit', CAST(N'2024-12-11' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'abb4682b-2180-48fc-9e7f-d554ba19fb96', N'54c49a0b-5dc6-46f8-abf2-ed2d1e56da8c', N'5220054254149545', N'credit', CAST(N'2024-06-09' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'af8a43bb-6cde-4a84-b1b3-f02e4b60c802', N'789de9f0-5ef0-46cc-bb19-fbe4928474e6', N'4892922136696182', N'debit', CAST(N'2025-04-05' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'afd79f74-1632-4615-b29e-b588f91a3c6b', N'2229fe26-cc7f-4a58-9caf-d79a7f45b93e', N'5291855267769598', N'credit', CAST(N'2024-05-28' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'bb85940c-7b7b-4564-8bd9-4ebfeaa6efd3', N'71de6c84-d689-4792-b730-7711deb2a408', N'375439313837441', N'credit', CAST(N'2025-02-12' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'bbc627dc-8df0-4554-b947-c42dda198e80', N'71c0f7ab-b701-45f0-9c94-802383b3cc36', N'377724444087940', N'credit', CAST(N'2024-07-24' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'bc790da8-8344-45d8-81e0-cec855f426df', N'1d97bce1-5c94-49e4-8e2a-6ad56b99afb0', N'613800975980634856', N'credit', CAST(N'2024-05-04' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'bd802465-1ceb-4a78-b614-3665f9e43f5d', N'a448f319-9dc4-4c02-b016-e1eab2b49629', N'4756229042584', N'debit', CAST(N'2024-06-05' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'c58239ed-0f10-46f8-8f04-6be6b46ab738', N'c50f01a9-441b-4a71-81c8-9f2a78288a92', N'5521135302233302', N'credit', CAST(N'2024-09-08' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'c9db9e10-b33f-4b4c-bd52-7d858865e3a0', N'65b4514d-4bbb-4aed-b0e0-859e1bef135e', N'619687707710162121', N'credit', CAST(N'2025-02-10' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'cdaf34fc-faff-42c7-acec-4da4ee7ba758', N'5b98a4b0-ee51-4b17-9584-d5ae35ce9e6b', N'600363176843694650', N'credit', CAST(N'2024-11-26' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'd1694652-37d3-429b-860b-6cef77a4085a', N'e0c672fd-8182-42b1-8a70-2138f223c47c', N'617944472523412766', N'debit', CAST(N'2024-12-27' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'd1b0328a-df83-4591-a80a-b738fc7c3942', N'c098f0dd-6434-4f69-afdd-d756849fe1fd', N'607850051406805644', N'credit', CAST(N'2024-05-16' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'da687eb9-0534-45db-a0a6-ad3c3b382aba', N'318c43bf-9511-4030-bd13-81a47a4b8cac', N'341077032205020', N'credit', CAST(N'2025-01-24' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'dd723f42-f1a3-476b-ba1d-1eba67eaccf2', N'07a36a4b-7943-4634-b17a-7c7eb4407cd3', N'615184939633015120', N'debit', CAST(N'2025-02-04' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'def643b2-3d6a-4537-82d5-e7f1c55a3928', N'9cd97ecb-58c9-4610-b4b1-d9f72bcae7f7', N'603148603529228244', N'debit', CAST(N'2025-01-09' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'e4390634-3a87-46dd-94d2-30072526877c', N'1118a259-aa7d-402b-9f1f-72555ed15180', N'374649129046768', N'debit', CAST(N'2024-05-07' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'e98e8a7c-dfaa-46d9-934f-f0dd090c18fd', N'418a133e-5e1f-4377-8d48-63de24b5b08e', N'611343983846791629', N'credit', CAST(N'2024-04-30' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'eed6b346-1810-439c-a698-67c3045fed41', N'85202b58-ec17-4407-ae0b-fab4ae861dac', N'5133628803898953', N'credit', CAST(N'2024-05-31' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'f19c2f88-8f1c-4b08-8613-a9f8e5db4d01', N'8d7d7e4b-11a9-47e3-bca0-8f3aa0bada73', N'614962358423715800', N'debit', CAST(N'2024-06-14' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'f24ceacf-1ff4-46c1-a0b2-dcf676ce244b', N'92ffabae-dab4-4737-8b26-ee60ed598cea', N'5208907834449147', N'credit', CAST(N'2025-03-29' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'f36a20ae-e574-452a-94b4-528c5cfc4eb9', N'ca19992d-7bc5-4903-8fba-699825411b95', N'4458294071407850', N'credit', CAST(N'2024-08-23' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'f38abe62-15f8-4f4a-a720-ac5c1dd4889a', N'bf4afaa6-c52c-4b4e-b7f8-543eeb1ec49c', N'4725116332578129', N'debit', CAST(N'2024-05-19' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'f5a3cbeb-0977-4b62-b917-f8b94a3b47bb', N'c4dd8020-5b57-4739-9d49-0f7172ffaf3f', N'373517598275455', N'credit', CAST(N'2024-07-09' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'fa5f5af7-93fc-4fcf-b579-556f21c23c42', N'4aab87c4-eb74-4e4e-ab8f-c13638276de1', N'4413265879297', N'credit', CAST(N'2024-04-30' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'fa7fde94-f537-4cb0-8942-d8f9adb6cbbb', N'dfd76a72-6dbc-4b94-a856-b77dd59d3b4a', N'345881261929900', N'credit', CAST(N'2025-03-25' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'fc77cc15-6ecd-4536-93c3-88d9826c56a9', N'905660c8-d6a7-40e9-9be3-e6711d22efb6', N'601951306789429060', N'credit', CAST(N'2024-10-03' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'fd43dd7e-fb80-4eff-9018-2feefab10d55', N'eae2bb46-3bd9-4bd6-a6b7-1b2efdc1911a', N'348046611982764', N'credit', CAST(N'2025-02-10' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'fdde1b9c-a3da-409e-9f0f-0b47a76eca8a', N'309d1066-7bcf-4772-9c5f-16aff605512e', N'4726759869796926', N'debit', CAST(N'2024-05-13' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'fe9f8279-255f-4d0e-a7c3-18eac663f1c6', N'17a9ed0a-5ed3-41d6-9e20-df434296c83d', N'613495382506603871', N'credit', CAST(N'2025-03-24' AS Date))
INSERT [dbo].[cards] ([card_id], [account_id], [card_number], [card_type], [expiration_date]) VALUES (N'fff0ab15-2876-4858-8420-dc43de17f3ce', N'5ea6c838-111c-484c-9b2b-bc4b5776f48f', N'617107804877836567', N'debit', CAST(N'2024-07-17' AS Date))
GO
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'079cd6ce-04a8-4c55-8c2b-b93189e9050a', N'Sergeant', N'Maith', N'sergeant.maith@aol.com', N'(512) 551-9311', N'11221 Bentwood Lane, Austin, Texas, United States, 78778', CAST(N'2024-04-25T21:26:38.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'0bedb8d0-0c5a-48a9-bae1-5b1fbecf4a10', N'Shaine', N'Matic', N'shaine.matic@hotmail.com', N'(904) 114-8620', N'2563 Bladewood Court, Jacksonville, Florida, United States, 32230', CAST(N'2024-04-25T19:31:13.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'0ca06e8d-a7a2-40c4-893b-128336ffdf54', N'Buddie', N'Sandison', N'buddie.sandison@yahoo.co.uk', N'(205) 075-5889', N'8159 Peterson Place, Birmingham, Alabama, United States, 35231', CAST(N'2024-04-25T21:49:02.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'13aac759-5c49-42dc-9693-0f46cb1337bb', N'Stephanus', N'Frear', N'stephanus.frear@hotmail.com', N'(228) 427-9642', N'5521 Lancaster Lane, Gulfport, Mississippi, United States, 39505', CAST(N'2024-04-25T23:38:56.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'14f35ff7-5574-4e12-ad89-7e7704a02e62', N'Corette', N'Vicent', N'corette.vicent@hotmail.com', N'(860) 119-3127', N'12466 Usher Place, Hartford, Connecticut, United States, 06145', CAST(N'2024-04-25T19:18:36.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'1833e0d4-fd6c-4474-b416-3ce9e539b363', N'Devon', N'McQuode', N'devon.mcquode@laposte.net', N'(415) 371-6505', N'7668 Rainbow Blvd., San Francisco, California, United States, 94147', CAST(N'2024-04-25T18:42:16.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'1b056bda-e6c8-46bb-a706-8db8c2e53061', N'Jacquenette', N'Hilldrup', N'jacquenette.hilldrup@gmail.com', N'(504) 592-9957', N'2042 Jonquil Place, New Orleans, Louisiana, United States, 70160', CAST(N'2024-04-25T22:40:40.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'1ea5ec60-3f36-4896-af24-13ee03bf06d9', N'Bobette', N'Shambrooke', N'bobette.shambrooke@hotmail.fr', N'(269) 629-9553', N'6747 Orgovan Avenue, Kalamazoo, Michigan, United States, 49048', CAST(N'2024-04-25T22:38:27.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'1f2aa50e-b682-43da-b36e-f33d041691dc', N'Donnajean', N'Amerighi', N'donnajean.amerighi@yahoo.de', N'(559) 566-8407', N'10301 Viking Place, Fresno, California, United States, 93773', CAST(N'2024-04-25T20:37:09.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'1f72084e-90f3-4334-9b8f-a3b350c2beb0', N'Barbabra', N'Swires', N'barbabra.swires@hotmail.com', N'(570) 979-3301', N'6755 Incorvaia Way, Wilkes Barre, Pennsylvania, United States, 18768', CAST(N'2024-04-26T01:02:12.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'20b542e7-3b96-4059-b30a-6d09832e17de', N'Sandro', N'Alten', N'sandro.alten@yahoo.com.br', N'(719) 485-8050', N'11759 Panigoni Avenue, Colorado Springs, Colorado, United States, 80920', CAST(N'2024-04-25T16:58:10.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'23fd617f-9912-4a67-b5cb-60147b25930c', N'Nester', N'Niccolls', N'nester.niccolls@hotmail.com', N'(864) 745-5159', N'294 Parrish Place, Spartanburg, South Carolina, United States, 29305', CAST(N'2024-04-25T20:18:28.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'26ae893b-6b51-41b9-9b07-a8d07e8a2979', N'Rebekah', N'Conkie', N'rebekah.conkie@yahoo.co.jp', N'(407) 279-4605', N'6619 Nueva Place, Kissimmee, Florida, United States, 34745', CAST(N'2024-04-26T00:45:35.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'27693ec7-45c9-4230-89d2-d0c98654cde7', N'Sidonnie', N'Marks', N'sidonnie.marks@gmail.com', N'(806) 099-5783', N'8993 Gaitanos Place, Amarillo, Texas, United States, 79165', CAST(N'2024-04-25T20:57:32.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'287bf982-89ce-44b5-bfdd-49407600309a', N'Niel', N'Yuryatin', N'niel.yuryatin@mail.ru', N'(615) 770-5635', N'11203 Wentworth Lane, Nashville, Tennessee, United States, 37235', CAST(N'2024-04-25T21:08:51.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'29f948c1-0d27-4e13-9126-498a6e51a079', N'Spike', N'Sill', N'spike.sill@hotmail.com', N'(914) 513-6574', N'3253 Cedar Ridge Place, Mount Vernon, New York, United States, 10557', CAST(N'2024-04-25T22:35:52.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'33716558-b6fb-43ec-91a8-59207fe42376', N'Billye', N'Lyfe', N'billye.lyfe@gmail.com', N'(727) 018-6475', N'14303 Morton Lane, Tampa, Florida, United States, 33625', CAST(N'2024-04-25T23:32:50.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'357e3969-87b3-48e9-bd0b-4a658de0dd38', N'Meggi', N'MacDermott', N'meggi.macdermott@yahoo.com', N'(702) 378-5984', N'8016 Mayberry Court, North Las Vegas, Nevada, United States, 89087', CAST(N'2024-04-25T15:52:54.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'3701903e-265f-402d-b8f9-5e46a67a89a6', N'Horst', N'Morecomb', N'horst.morecomb@mail.ru', N'(412) 835-1593', N'3520 Beacon Hill Court, Pittsburgh, Pennsylvania, United States, 15261', CAST(N'2024-04-25T23:23:46.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'37abd855-71e9-4ded-87fe-901c4ccb3d3c', N'Jyoti', N'Treanor', N'jyoti.treanor@yahoo.com', N'(253) 948-7342', N'633 Kilarny Place, Tacoma, Washington, United States, 98481', CAST(N'2024-04-25T21:10:29.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'3a57a285-56e7-4900-bc63-d044f2247ff1', N'Boy', N'Rowesby', N'boy.rowesby@rediffmail.com', N'(540) 195-3085', N'3062 Butler Court, Roanoke, Virginia, United States, 24024', CAST(N'2024-04-25T17:20:28.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'3eec958e-8cd8-426e-8603-eac1c9b2c004', N'Galen', N'Biddy', N'galen.biddy@orange.fr', N'(859) 016-8839', N'14370 Ludlow Place, Lexington, Kentucky, United States, 40586', CAST(N'2024-04-25T21:12:54.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'3f5ab011-f526-4bbd-8ab8-8a67ad95c5bf', N'Olivia', N'Speedin', N'olivia.speedin@gmail.com', N'(202) 594-9821', N'12264 Quincy Court, Washington, District of Columbia, United States, 20566', CAST(N'2024-04-25T17:06:08.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'43776145-9002-47aa-a868-c0ca95951f5b', N'Jamie', N'Beirne', N'jamie.beirne@rediffmail.com', N'(602) 646-0995', N'9686 Brunell Street, Glendale, Arizona, United States, 85311', CAST(N'2024-04-26T00:14:59.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'43803350-bfb2-46b7-8949-24dc4b72fbf3', N'Anabella', N'Vaulkhard', N'anabella.vaulkhard@hotmail.com', N'(770) 565-3195', N'6897 Indale Place, Lawrenceville, Georgia, United States, 30045', CAST(N'2024-04-25T19:40:57.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'462d21d0-7672-428a-abf7-04c18a1efde8', N'Zebedee', N'Goley', N'zebedee.goley@gmail.com', N'(757) 816-0102', N'9705 Madero Drive, Hampton, Virginia, United States, 23668', CAST(N'2024-04-25T17:29:05.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'4837eb17-36bb-4c4b-bb49-bc368edb173a', N'Rafe', N'Cornwell', N'rafe.cornwell@hotmail.com', N'(806) 635-2657', N'8919 Mcnair Terrace, Lubbock, Texas, United States, 79410', CAST(N'2024-04-25T21:42:21.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'4a150c66-0c2b-4626-8e66-4035a87c1ab0', N'Arlina', N'Tofts', N'arlina.tofts@aol.com', N'(202) 150-2339', N'12561 Rhett Road, Washington, District of Columbia, United States, 20436', CAST(N'2024-04-25T21:56:23.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'50acac78-1c19-491e-8e95-2787664d9090', N'Ikey', N'Le Fevre', N'ikey.lefevre@hotmail.com', N'(330) 883-4358', N'1160 Teakwood Lane, Akron, Ohio, United States, 44315', CAST(N'2024-04-25T20:20:35.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'52d177ad-467a-400c-9f5e-a51bfffce616', N'Donny', N'Bamsey', N'donny.bamsey@aliceadsl.fr', N'(805) 328-1517', N'6314 Goldenrod Court, San Luis Obispo, California, United States, 93407', CAST(N'2024-04-26T00:30:15.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'53a68a7b-f69c-4a25-8846-0f06497a3b6d', N'Anjanette', N'Callf', N'anjanette.callf@hotmail.com', N'(212) 976-3463', N'644 Berwyn Way, New York City, New York, United States, 10039', CAST(N'2024-04-25T19:01:32.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'57829c08-247e-4dec-b528-cd1099fc1e81', N'Meade', N'McSkin', N'meade.mcskin@hotmail.com', N'(858) 654-8175', N'11810 Rose Croft Terrace, San Diego, California, United States, 92121', CAST(N'2024-04-25T16:00:25.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'585b6bfa-e33a-4e75-8d2e-5cf1e4a42197', N'Antonetta', N'Cavey', N'antonetta.cavey@yahoo.com', N'(304) 333-9094', N'173 Kingfisher Court, Charleston, West Virginia, United States, 25305', CAST(N'2024-04-25T19:28:31.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'5b3fb023-fd43-4cae-8783-ef1c98d11b38', N'Estrella', N'Glentworth', N'estrella.glentworth@aol.com', N'(941) 337-2078', N'163 Olar Court, Port Charlotte, Florida, United States, 33954', CAST(N'2024-04-25T19:08:53.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'5c41586b-f7bf-41fa-883a-7b9cb1c4c849', N'Giordano', N'Schutter', N'giordano.schutter@yahoo.com', N'(717) 057-6564', N'12401 Shubrick Court, Harrisburg, Pennsylvania, United States, 17140', CAST(N'2024-04-25T19:47:14.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'5d8912f2-8074-4f41-b002-e0c789e7f718', N'Hillie', N'Wyrall', N'hillie.wyrall@gmail.com', N'(702) 506-6469', N'7449 Montbrook Place, Las Vegas, Nevada, United States, 89140', CAST(N'2024-04-25T16:04:50.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'61ac2df4-4e87-4f00-af98-a9c55edbdd80', N'Chanda', N'Brunnstein', N'chanda.brunnstein@hotmail.com', N'(831) 141-9049', N'9822 Leisure Street, Santa Cruz, California, United States, 95064', CAST(N'2024-04-25T17:14:48.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'623e0b78-6b7c-4e98-a46a-c96d1c607817', N'Kellia', N'Bowller', N'kellia.bowller@neuf.fr', N'(202) 770-5130', N'14520 Marlin Place, Washington, District of Columbia, United States, 20508', CAST(N'2024-04-25T20:26:34.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'69514bb4-0f65-4e74-b29e-92b1febb7933', N'Ogdon', N'Ferrand', N'ogdon.ferrand@gmail.com', N'(713) 537-3924', N'13687 Randolph Loop, Houston, Texas, United States, 77299', CAST(N'2024-04-26T00:52:34.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'6a9b75fb-c1c5-4e1a-a94e-07cbb5c41837', N'Gustie', N'Ravillas', N'gustie.ravillas@gmail.com', N'(786) 358-6037', N'13515 Kauska Way, Miami, Florida, United States, 33111', CAST(N'2024-04-25T18:28:29.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'6ae55628-7994-4e93-b964-f75e00363d72', N'Philippe', N'Bartolomeazzi', N'philippe.bartolomeazzi@hotmail.com', N'(402) 735-5396', N'3763 Impala Place, Lincoln, Nebraska, United States, 68524', CAST(N'2024-04-25T18:36:32.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'6b612ed4-f731-4963-85f3-780a438e0fad', N'Kendricks', N'Casper', N'kendricks.casper@hotmail.com', N'(559) 010-2031', N'11145 Becky Court, Fresno, California, United States, 93726', CAST(N'2024-04-25T16:31:00.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'6b7b3dfa-9959-401f-9b8c-fce6948abc45', N'Seka', N'Rabbe', N'seka.rabbe@aol.com', N'(913) 425-9090', N'7184 Williamson Drive, Shawnee Mission, Kansas, United States, 66286', CAST(N'2024-04-25T23:00:22.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'6ca0328f-1be0-4205-9a57-59cef27a1067', N'Wilden', N'De Paoli', N'wilden.depaoli@wanadoo.fr', N'(915) 400-2489', N'3582 Bassinger Court, El Paso, Texas, United States, 88546', CAST(N'2024-04-25T21:29:24.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'6daa0a7c-3ca5-4ace-9d6c-b119d9067a6a', N'Rachael', N'Giacopetti', N'rachael.giacopetti@gmail.com', N'(859) 459-1708', N'3788 Shelburne Lane, Lexington, Kentucky, United States, 40546', CAST(N'2024-04-25T16:32:27.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'6e360958-11c9-41fc-a89f-4238b8a0ae24', N'Bendite', N'Godsafe', N'bendite.godsafe@gmail.com', N'(808) 649-2746', N'2948 Pleasant View Place, Honolulu, Hawaii, United States, 96845', CAST(N'2024-04-25T18:22:00.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'6f6a46c1-26ae-47c8-82aa-34027c84af78', N'Feodora', N'Muress', N'feodora.muress@hotmail.com', N'(405) 031-2886', N'8978 Seymour Avenue, Oklahoma City, Oklahoma, United States, 73129', CAST(N'2024-04-25T16:40:02.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'719c88a7-ba09-4109-a4f8-ba659d01ebf6', N'Dorella', N'Clavey', N'dorella.clavey@yahoo.com', N'(707) 624-4058', N'14554 Maxwell Terrace, Petaluma, California, United States, 94975', CAST(N'2024-04-26T00:25:10.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'79dcf8ce-329d-48a8-ac2c-9fa869b4ac42', N'Daisie', N'Gabala', N'daisie.gabala@gmail.com', N'(919) 158-9579', N'8101 Maynard Path, Raleigh, North Carolina, United States, 27610', CAST(N'2024-04-25T17:00:11.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'7ab376ee-2fca-4f08-98aa-9b93cc0fc972', N'Shalne', N'Lowers', N'shalne.lowers@gmail.com', N'(614) 967-0772', N'5682 Hopewell Street, Columbus, Ohio, United States, 43240', CAST(N'2024-04-25T16:49:32.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'7f18c59c-3e61-43f6-946f-d0b81fbd3cc7', N'Hobie', N'Skirving', N'hobie.skirving@yahoo.com', N'(510) 572-8801', N'7611 Wax Berry Court, Richmond, California, United States, 94807', CAST(N'2024-04-25T17:35:30.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'7f42152e-6a93-4d03-a9c9-ee0830c5096f', N'Hortense', N'Munsey', N'hortense.munsey@bol.com.br', N'(626) 472-3657', N'5264 Wyatt Avenue, Pasadena, California, United States, 91117', CAST(N'2024-04-25T19:56:43.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'82cac284-ec70-4be8-a43e-b002fc419e26', N'Noellyn', N'Crinage', N'noellyn.crinage@rediffmail.com', N'(770) 368-6780', N'3894 Cruz Court, Marietta, Georgia, United States, 30061', CAST(N'2024-04-26T00:00:47.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'85916c42-22cb-4462-9fa2-9c45feea827e', N'Jodi', N'McIlwreath', N'jodi.mcilwreath@hotmail.com', N'(574) 013-3213', N'6048 Impala Place, South Bend, Indiana, United States, 46634', CAST(N'2024-04-26T00:10:41.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'86f4ec23-7064-4bb5-9aaf-b8e98e8d95ec', N'Mirelle', N'Nolan', N'mirelle.nolan@comcast.net', N'(520) 573-1239', N'8635 Rieger Road, Tucson, Arizona, United States, 85715', CAST(N'2024-04-25T18:08:03.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'870ae237-d669-42dd-b283-99c1219bf349', N'Normie', N'McNabb', N'normie.mcnabb@hotmail.com', N'(225) 812-2851', N'3569 Norwood Street, Baton Rouge, Louisiana, United States, 70810', CAST(N'2024-04-25T16:11:26.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'8e07d624-a56d-4734-a552-2b3985adedbd', N'Lionel', N'McCudden', N'lionel.mccudden@hotmail.com', N'(415) 086-0354', N'1199 Santana Way, San Francisco, California, United States, 94159', CAST(N'2024-04-25T18:49:07.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'9253d6d7-b356-4e9e-8fa4-e60c1d0327cc', N'Benjie', N'Moore', N'benjie.moore@orange.fr', N'(915) 271-1447', N'2497 Captiva Court, El Paso, Texas, United States, 88519', CAST(N'2024-04-25T22:11:41.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'93718b0c-9337-4efa-bd48-51713fb1523c', N'Emmy', N'Votier', N'emmy.votier@hotmail.com', N'(315) 152-4192', N'2129 Ridgeville Road, Syracuse, New York, United States, 13251', CAST(N'2024-04-25T22:23:11.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'9d78736f-df51-4622-9cb1-c4db88dca2d0', N'Swen', N'Crowley', N'swen.crowley@gmail.com', N'(203) 751-2379', N'9102 McKay Avenue, Waterbury, Connecticut, United States, 06721', CAST(N'2024-04-25T15:51:30.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'9da1cc29-9c8b-498c-bbbd-c412a8115cc8', N'Lillian', N'Micheu', N'lillian.micheu@terra.com.br', N'(215) 019-1137', N'8911 Keeley Court, Philadelphia, Pennsylvania, United States, 19160', CAST(N'2024-04-25T20:42:05.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'9e5061d8-a27f-44cc-a390-5f9ab4d00178', N'Elbert', N'Gogie', N'elbert.gogie@hotmail.co.uk', N'(603) 734-3683', N'4278 Inner Circle, Manchester, New Hampshire, United States, 03105', CAST(N'2024-04-25T17:58:30.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'9f2f61c6-ee32-4494-85a3-2425d533a5b8', N'Kimble', N'McConaghy', N'kimble.mcconaghy@yahoo.com', N'(419) 566-8488', N'12197 Cumberland Court, Toledo, Ohio, United States, 43666', CAST(N'2024-04-25T18:01:01.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'a23ae674-314f-4a4b-845a-ae0ff78d3512', N'Glory', N'McCarter', N'glory.mccarter@gmail.com', N'(339) 541-4189', N'12259 Armondo Drive, Woburn, Massachusetts, United States, 01813', CAST(N'2024-04-25T23:31:31.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'a34887df-cb28-4cab-a2ab-0f7de63719b9', N'Jeniece', N'Mangeon', N'jeniece.mangeon@voila.fr', N'(804) 953-0789', N'14733 Overstreet Place, Richmond, Virginia, United States, 23220', CAST(N'2024-04-25T21:37:19.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'a424f2b5-0890-4fc1-a71e-9ea7547a5a25', N'Whitby', N'Oldroyde', N'whitby.oldroyde@gmail.com', N'(608) 132-1122', N'2180 Germakian Lane, Madison, Wisconsin, United States, 53705', CAST(N'2024-04-25T22:50:33.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'a99c66ac-ae2a-4375-b15c-9b1694200e6d', N'Horacio', N'Baxill', N'horacio.baxill@centurytel.net', N'(510) 201-3623', N'2928 Berwyn Way, Oakland, California, United States, 94611', CAST(N'2024-04-25T23:05:40.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'a9de1fc5-3ba9-4088-8ee6-5a75104f2c7d', N'Emmye', N'Chappelow', N'emmye.chappelow@hotmail.com', N'(814) 619-2939', N'12683 San Clemente Court, Erie, Pennsylvania, United States, 16550', CAST(N'2024-04-25T18:25:26.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'abd49d49-237d-4d28-b3ea-9d19661fcf9b', N'Miller', N'Ipplett', N'miller.ipplett@hotmail.com', N'(309) 402-0367', N'9991 Delfin Road, Peoria, Illinois, United States, 61651', CAST(N'2024-04-25T17:39:35.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'b3e475f6-203f-474f-a30c-243fe885b3e1', N'Mikol', N'De Maria', N'mikol.demaria@gmail.com', N'(720) 796-5480', N'155 Trellis Lane, Littleton, Colorado, United States, 80126', CAST(N'2024-04-25T23:28:07.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'b4a5aa8b-b1f2-478d-b60c-7efd3b198ee5', N'Nathanael', N'Nuzzetti', N'nathanael.nuzzetti@hotmail.com', N'(209) 251-9348', N'8595 Carriage Hill Way, Fresno, California, United States, 93721', CAST(N'2024-04-25T23:13:56.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'b5c6a70e-f40c-43ac-9291-418539d54ae7', N'Sean', N'Palffrey', N'sean.palffrey@gmail.com', N'(916) 802-0917', N'469 Champion Avenue, Sacramento, California, United States, 95828', CAST(N'2024-04-25T20:07:26.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'b9779359-2984-4b3a-83cd-0e0eab80293c', N'Stanislaus', N'Morecombe', N'stanislaus.morecombe@yahoo.com', N'(812) 022-1764', N'295 Fort Mill Court, Evansville, Indiana, United States, 47737', CAST(N'2024-04-26T00:59:36.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'b980c9fc-c205-4042-81ef-17a613787208', N'Armando', N'Dearl', N'armando.dearl@hotmail.com', N'(574) 812-3117', N'2268 Glencoe Court, South Bend, Indiana, United States, 46614', CAST(N'2024-04-25T22:29:42.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'ba054855-8fa2-4f85-965a-6ba3b5fc13d3', N'Karl', N'Rowlatt', N'karl.rowlatt@yahoo.com', N'(646) 521-3208', N'3047 Kerry Place, New York City, New York, United States, 10060', CAST(N'2024-04-25T19:07:36.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'bb09df35-4fb6-42be-a106-f0f1f1a74012', N'Gerianna', N'Bagworth', N'gerianna.bagworth@gmail.com', N'(520) 898-2462', N'13575 Hook Hollow Terrace, Tucson, Arizona, United States, 85725', CAST(N'2024-04-25T22:18:09.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'c7a3c75f-3b79-4fdb-a4ab-52a54401b875', N'Cleavland', N'Yurkevich', N'cleavland.yurkevich@mac.com', N'(217) 117-2926', N'13531 Tripp Terrace, Springfield, Illinois, United States, 62718', CAST(N'2024-04-25T21:00:13.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'c7bb143b-430d-4bbc-9ab1-031826291851', N'Antonietta', N'Guswell', N'antonietta.guswell@hotmail.com', N'(208) 529-9852', N'13204 Laurel Run, Boise, Idaho, United States, 83757', CAST(N'2024-04-25T23:45:51.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'cd125a77-15a1-4c04-aaed-41a05195225b', N'Bessy', N'Exley', N'bessy.exley@yahoo.com', N'(850) 279-1291', N'10527 Gabriele Place, Tallahassee, Florida, United States, 32399', CAST(N'2024-04-25T20:35:51.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'd01d990c-8cbd-4b0f-87b3-4c31fafbf3d5', N'Ethyl', N'Ditchburn', N'ethyl.ditchburn@yahoo.com', N'(718) 643-5806', N'12077 Cherry Vale Place, Jamaica, New York, United States, 11447', CAST(N'2024-04-25T20:44:55.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'd46ba1b1-9ff9-42e1-b7ad-7138cee43bf2', N'Roseann', N'Bonfield', N'roseann.bonfield@hotmail.com', N'(434) 309-0314', N'8795 Sylewood Avenue, Manassas, Virginia, United States, 22111', CAST(N'2024-04-26T00:18:16.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'd933fcc1-a91f-4051-9cc1-58e1bf6be236', N'Broderick', N'Coolbear', N'broderick.coolbear@gmail.com', N'(202) 906-1474', N'4629 Penno Place, Washington, District of Columbia, United States, 20430', CAST(N'2024-04-25T23:03:43.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'daf898aa-13cd-465a-b2ed-ce3605ff9cc2', N'Byrom', N'Copnell', N'byrom.copnell@uol.com.br', N'(205) 409-8341', N'6488 Gable Place, Birmingham, Alabama, United States, 35263', CAST(N'2024-04-25T20:10:16.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'db0df896-914e-491f-9e31-454b9f1d3c7f', N'Glenna', N'Lehrian', N'glenna.lehrian@hotmail.com', N'(314) 201-5509', N'2753 Carrollton Court, Saint Louis, Missouri, United States, 63169', CAST(N'2024-04-25T18:13:23.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'dc0f5f48-84ef-4f9b-bd05-ef9217f050fe', N'Sherill', N'Downham', N'sherill.downham@gmail.com', N'(361) 135-4497', N'9484 Callaway Drive, Corpus Christi, Texas, United States, 78470', CAST(N'2024-04-25T17:19:01.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'e19d7be6-0155-4cb3-86ee-ba31a6ff5de1', N'Alon', N'Francomb', N'alon.francomb@t-online.de', N'(425) 423-1489', N'6862 Carvello Drive, Seattle, Washington, United States, 98133', CAST(N'2024-04-25T20:43:12.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'e8a917b4-9641-4271-91a2-2a0ef3477c76', N'Auberta', N'Whal', N'auberta.whal@hotmail.com', N'(540) 387-9947', N'8599 Ridley Terrace, Roanoke, Virginia, United States, 24004', CAST(N'2024-04-25T23:49:55.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'ea53056c-33eb-49f9-b00d-71b8b74f5829', N'Carlye', N'Clouter', N'carlye.clouter@gmail.com', N'(626) 337-4202', N'3299 Butler Court, Burbank, California, United States, 91520', CAST(N'2024-04-26T00:38:13.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'ed4658f1-c11e-484a-b761-c911885548c2', N'Ellie', N'Rablin', N'ellie.rablin@libero.it', N'(407) 937-5072', N'1236 Merida Circle, Orlando, Florida, United States, 32891', CAST(N'2024-04-25T18:56:26.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'ed5f70a9-36e5-433b-abbc-fed08b27bb16', N'Gardy', N'Fritschel', N'gardy.fritschel@ymail.com', N'(972) 977-7822', N'3780 Berrington Loop, Denton, Texas, United States, 76210', CAST(N'2024-04-25T23:52:17.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'ee6cebc9-6876-4561-9355-b84013639e66', N'Mackenzie', N'Calverley', N'mackenzie.calverley@yahoo.com', N'(405) 815-3548', N'4330 Clio Lane, Oklahoma City, Oklahoma, United States, 73142', CAST(N'2024-04-25T20:00:41.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'EE96E9D9-3815-45D9-ABBF-E61175D5C974', N'Alisha', N'Rahman', N'alisha@example.com', N'081234567890', N'Jl. Mawar No. 10, Semarang', CAST(N'2025-05-05T20:06:20.277' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'ef255303-e28b-4229-aa6f-99eb4f67a81c', N'Marv', N'Husset', N'marv.husset@yahoo.com', N'(407) 501-1223', N'7296 Gatehouse Terrace, Orlando, Florida, United States, 32868', CAST(N'2024-04-25T20:50:13.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'ef998517-9d3b-429c-be1b-5b164ba2afe2', N'Marcelle', N'Berrie', N'marcelle.berrie@hotmail.com', N'(407) 515-1258', N'9020 Wresh Way, Orlando, Florida, United States, 32859', CAST(N'2024-04-26T00:16:57.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'f023ea3c-6500-4297-868e-abd3043b97c1', N'Gale', N'Creaven', N'gale.creaven@sympatico.ca', N'(210) 440-2198', N'11290 Nackman Place, San Antonio, Texas, United States, 78265', CAST(N'2024-04-25T17:43:24.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'f1082db9-8d80-4f63-9af8-db2ed4c41080', N'Salomo', N'Saer', N'salomo.saer@bigpond.com', N'(862) 854-8184', N'12857 Brighton Drive, Paterson, New Jersey, United States, 07505', CAST(N'2024-04-25T22:02:39.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'f40f3b32-6b03-4f88-896a-949bb777a247', N'Padget', N'Waything', N'padget.waything@gmail.com', N'(704) 864-4502', N'5929 Turtle Street, Charlotte, North Carolina, United States, 28242', CAST(N'2024-04-25T17:52:22.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'f832a165-6ce7-4d54-9cf4-2b58ad4b4cf5', N'Hilliard', N'Milmoe', N'hilliard.milmoe@gmail.com', N'(339) 079-5111', N'8969 Tranquility Lane, Boston, Massachusetts, United States, 02163', CAST(N'2024-04-25T16:23:03.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'f8628b73-c900-4973-849e-22aa8e42fc33', N'Luca', N'Courtney', N'luca.courtney@hotmail.com', N'(971) 493-3208', N'2377 Enrique Drive, Portland, Oregon, United States, 97240', CAST(N'2024-04-25T21:21:20.000' AS DateTime))
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'fa5b05d5-cd6d-4e43-840d-4e368a1dac48', N'Shanna', N'Oaten', N'shanna.oaten@rediffmail.com', N'(717) 310-2552', N'552 Eastmont Court, Harrisburg, Pennsylvania, United States, 17121', CAST(N'2024-04-26T00:05:01.000' AS DateTime))
GO
INSERT [dbo].[customers] ([customer_id], [first_name], [last_name], [email], [phone_number], [address], [created_at]) VALUES (N'fd29af21-54cd-42a1-a4d7-40890f6dd658', N'Yardley', N'Gillingwater', N'yardley.gillingwater@hotmail.com', N'(901) 844-1964', N'11286 Makoski Place, Memphis, Tennessee, United States, 38114', CAST(N'2024-04-25T16:15:43.000' AS DateTime))
GO
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'00d66b19-0e2f-4bb1-8f27-dc06280f283a', N'287bf982-89ce-44b5-bfdd-49407600309a', CAST(39958.46 AS Decimal(18, 2)), CAST(17.00 AS Decimal(5, 2)), 5, CAST(N'2025-04-27' AS Date), CAST(N'2024-05-19' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'065b85a1-eafd-4486-84ce-72928fcbe70b', N'0ca06e8d-a7a2-40c4-893b-128336ffdf54', CAST(60014.10 AS Decimal(18, 2)), CAST(14.00 AS Decimal(5, 2)), 8, CAST(N'2024-11-22' AS Date), CAST(N'2025-03-05' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'0edcbb3d-5140-442d-9f48-674612922e8e', N'b3e475f6-203f-474f-a30c-243fe885b3e1', CAST(58881.74 AS Decimal(18, 2)), CAST(13.00 AS Decimal(5, 2)), 6, CAST(N'2024-11-16' AS Date), CAST(N'2024-06-10' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'15c936d8-9cfc-4671-903c-bd64c717a957', N'b980c9fc-c205-4042-81ef-17a613787208', CAST(54893.77 AS Decimal(18, 2)), CAST(13.00 AS Decimal(5, 2)), 4, CAST(N'2024-07-04' AS Date), CAST(N'2024-05-30' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'17d17992-ebb5-42e4-9253-325e463e2f94', N'29f948c1-0d27-4e13-9126-498a6e51a079', CAST(43771.07 AS Decimal(18, 2)), CAST(3.00 AS Decimal(5, 2)), 1, CAST(N'2025-01-10' AS Date), CAST(N'2024-09-12' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'185a419c-476d-450d-9f7d-ba89c22db819', N'870ae237-d669-42dd-b283-99c1219bf349', CAST(51288.19 AS Decimal(18, 2)), CAST(14.00 AS Decimal(5, 2)), 5, CAST(N'2024-05-03' AS Date), CAST(N'2024-06-09' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'1a410579-e174-4b63-8813-39a9e135a1e9', N'c7a3c75f-3b79-4fdb-a4ab-52a54401b875', CAST(42069.91 AS Decimal(18, 2)), CAST(5.00 AS Decimal(5, 2)), 7, CAST(N'2025-02-02' AS Date), CAST(N'2024-05-01' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'1ad861bb-05cf-41e0-9c6b-4ddca09021f8', N'719c88a7-ba09-4109-a4f8-ba659d01ebf6', CAST(50677.26 AS Decimal(18, 2)), CAST(8.00 AS Decimal(5, 2)), 5, CAST(N'2025-04-16' AS Date), CAST(N'2024-12-10' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'1d8a9786-f995-4e76-9e72-18956814ab04', N'1b056bda-e6c8-46bb-a706-8db8c2e53061', CAST(60627.80 AS Decimal(18, 2)), CAST(10.00 AS Decimal(5, 2)), 6, CAST(N'2024-08-10' AS Date), CAST(N'2024-11-02' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'1ed01141-0b39-4699-87f6-486d2bb56183', N'53a68a7b-f69c-4a25-8846-0f06497a3b6d', CAST(43376.53 AS Decimal(18, 2)), CAST(18.00 AS Decimal(5, 2)), 9, CAST(N'2024-10-08' AS Date), CAST(N'2024-06-26' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'205ce30d-eebe-45bd-b564-9edd917a3426', N'f832a165-6ce7-4d54-9cf4-2b58ad4b4cf5', CAST(55209.06 AS Decimal(18, 2)), CAST(8.00 AS Decimal(5, 2)), 2, CAST(N'2024-12-19' AS Date), CAST(N'2025-01-09' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'208b5b89-cbc2-4e18-93f2-0fb6d837500a', N'20b542e7-3b96-4059-b30a-6d09832e17de', CAST(48265.03 AS Decimal(18, 2)), CAST(15.00 AS Decimal(5, 2)), 7, CAST(N'2024-10-16' AS Date), CAST(N'2025-02-08' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'2424a4c1-6c58-4202-a1f0-b21226a05dad', N'1ea5ec60-3f36-4896-af24-13ee03bf06d9', CAST(43166.51 AS Decimal(18, 2)), CAST(10.00 AS Decimal(5, 2)), 7, CAST(N'2024-12-05' AS Date), CAST(N'2024-04-30' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'2588b70b-d89b-4e4a-b4ac-b4eac55e9fe7', N'26ae893b-6b51-41b9-9b07-a8d07e8a2979', CAST(58610.63 AS Decimal(18, 2)), CAST(10.00 AS Decimal(5, 2)), 7, CAST(N'2024-04-28' AS Date), CAST(N'2025-04-01' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'26136eb1-aded-470d-baa4-15e607e5db06', N'ef255303-e28b-4229-aa6f-99eb4f67a81c', CAST(56021.00 AS Decimal(18, 2)), CAST(22.00 AS Decimal(5, 2)), 11, CAST(N'2024-08-08' AS Date), CAST(N'2025-04-21' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'28d65366-4fa3-44eb-895d-9343fd626052', N'37abd855-71e9-4ded-87fe-901c4ccb3d3c', CAST(60259.49 AS Decimal(18, 2)), CAST(22.00 AS Decimal(5, 2)), 4, CAST(N'2024-10-14' AS Date), CAST(N'2025-02-02' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'2b3501ae-f9f2-484b-9503-6a103135898b', N'1833e0d4-fd6c-4474-b416-3ce9e539b363', CAST(57922.30 AS Decimal(18, 2)), CAST(21.00 AS Decimal(5, 2)), 10, CAST(N'2024-06-30' AS Date), CAST(N'2024-07-29' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'2b3f78ce-27bd-4317-a213-4eb0264d98a4', N'dc0f5f48-84ef-4f9b-bd05-ef9217f050fe', CAST(55892.32 AS Decimal(18, 2)), CAST(15.00 AS Decimal(5, 2)), 5, CAST(N'2024-11-26' AS Date), CAST(N'2024-12-29' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'2c2af935-222d-4c58-aa20-6340033addcc', N'ed5f70a9-36e5-433b-abbc-fed08b27bb16', CAST(48630.85 AS Decimal(18, 2)), CAST(10.00 AS Decimal(5, 2)), 8, CAST(N'2024-11-21' AS Date), CAST(N'2024-09-29' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'3353ed1e-9bab-4bc5-99e6-259dfb48c1de', N'ef998517-9d3b-429c-be1b-5b164ba2afe2', CAST(54457.39 AS Decimal(18, 2)), CAST(2.00 AS Decimal(5, 2)), 9, CAST(N'2024-05-06' AS Date), CAST(N'2024-07-24' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'39b7d0f0-d0d7-4b79-b09b-34af80424868', N'8e07d624-a56d-4734-a552-2b3985adedbd', CAST(52649.61 AS Decimal(18, 2)), CAST(4.00 AS Decimal(5, 2)), 4, CAST(N'2024-05-23' AS Date), CAST(N'2024-06-22' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'3c062dca-281c-4658-b34b-ef710b3f75d8', N'b5c6a70e-f40c-43ac-9291-418539d54ae7', CAST(47202.95 AS Decimal(18, 2)), CAST(18.00 AS Decimal(5, 2)), 6, CAST(N'2024-06-15' AS Date), CAST(N'2025-02-12' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'3d0f3146-c92e-4c37-80e8-f87cc134047c', N'f023ea3c-6500-4297-868e-abd3043b97c1', CAST(55210.20 AS Decimal(18, 2)), CAST(20.00 AS Decimal(5, 2)), 6, CAST(N'2024-05-30' AS Date), CAST(N'2025-02-07' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'4322003d-199e-48b4-af5f-d37689c8c71d', N'c7bb143b-430d-4bbc-9ab1-031826291851', CAST(40482.07 AS Decimal(18, 2)), CAST(15.00 AS Decimal(5, 2)), 4, CAST(N'2025-04-07' AS Date), CAST(N'2025-01-01' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'475f0739-0ae3-4697-bc84-f631e6f7c375', N'bb09df35-4fb6-42be-a106-f0f1f1a74012', CAST(55128.96 AS Decimal(18, 2)), CAST(1.00 AS Decimal(5, 2)), 3, CAST(N'2025-01-21' AS Date), CAST(N'2024-06-12' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'4e87bf47-4f56-4b1b-8f20-6aac69315e62', N'462d21d0-7672-428a-abf7-04c18a1efde8', CAST(52802.73 AS Decimal(18, 2)), CAST(11.00 AS Decimal(5, 2)), 8, CAST(N'2024-08-09' AS Date), CAST(N'2025-02-25' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'4f33fb1b-d9c8-4fe3-80c8-f0283541bcfa', N'079cd6ce-04a8-4c55-8c2b-b93189e9050a', CAST(38243.63 AS Decimal(18, 2)), CAST(16.00 AS Decimal(5, 2)), 10, CAST(N'2024-06-23' AS Date), CAST(N'2025-04-22' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'52919168-20b2-4c86-95e8-fc9af60229cd', N'82cac284-ec70-4be8-a43e-b002fc419e26', CAST(59943.95 AS Decimal(18, 2)), CAST(21.00 AS Decimal(5, 2)), 9, CAST(N'2025-04-14' AS Date), CAST(N'2025-01-13' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'540d065d-8c09-477f-a8a9-a24b67b37711', N'd46ba1b1-9ff9-42e1-b7ad-7138cee43bf2', CAST(43210.72 AS Decimal(18, 2)), CAST(2.00 AS Decimal(5, 2)), 7, CAST(N'2024-10-26' AS Date), CAST(N'2025-01-18' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'57e507a6-7ef9-4f63-b893-ce6deda96192', N'3eec958e-8cd8-426e-8603-eac1c9b2c004', CAST(42700.14 AS Decimal(18, 2)), CAST(23.00 AS Decimal(5, 2)), 3, CAST(N'2024-12-27' AS Date), CAST(N'2025-03-04' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'59293892-28d5-4cf9-a08c-6b78d5eb6015', N'7ab376ee-2fca-4f08-98aa-9b93cc0fc972', CAST(60862.44 AS Decimal(18, 2)), CAST(15.00 AS Decimal(5, 2)), 1, CAST(N'2024-09-01' AS Date), CAST(N'2025-03-15' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'5a3eed61-5aa9-4a49-ab64-8cbcc6b16e4f', N'e19d7be6-0155-4cb3-86ee-ba31a6ff5de1', CAST(57490.46 AS Decimal(18, 2)), CAST(15.00 AS Decimal(5, 2)), 2, CAST(N'2024-05-14' AS Date), CAST(N'2025-02-01' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'5c5e6a1f-8cb2-4108-8b86-33fab6995240', N'9f2f61c6-ee32-4494-85a3-2425d533a5b8', CAST(44026.28 AS Decimal(18, 2)), CAST(20.00 AS Decimal(5, 2)), 6, CAST(N'2024-10-28' AS Date), CAST(N'2024-09-26' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'62a82461-71e3-4172-8577-0aad1ca82be4', N'33716558-b6fb-43ec-91a8-59207fe42376', CAST(50394.51 AS Decimal(18, 2)), CAST(14.00 AS Decimal(5, 2)), 11, CAST(N'2024-12-23' AS Date), CAST(N'2024-12-23' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'67604701-5bda-4cd8-be5e-53b5ef6050b7', N'ea53056c-33eb-49f9-b00d-71b8b74f5829', CAST(42808.38 AS Decimal(18, 2)), CAST(14.00 AS Decimal(5, 2)), 5, CAST(N'2024-04-30' AS Date), CAST(N'2025-03-24' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'69a28e51-b8f6-4235-9761-8708889c055d', N'7f42152e-6a93-4d03-a9c9-ee0830c5096f', CAST(39471.44 AS Decimal(18, 2)), CAST(5.00 AS Decimal(5, 2)), 9, CAST(N'2024-09-13' AS Date), CAST(N'2025-02-20' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'6c20ef5c-77ac-4611-841e-e88f9a7efbc3', N'f1082db9-8d80-4f63-9af8-db2ed4c41080', CAST(44553.93 AS Decimal(18, 2)), CAST(7.00 AS Decimal(5, 2)), 4, CAST(N'2024-05-24' AS Date), CAST(N'2024-04-30' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'6e22338f-f27d-4d78-974c-e427d70d726e', N'52d177ad-467a-400c-9f5e-a51bfffce616', CAST(37898.81 AS Decimal(18, 2)), CAST(1.00 AS Decimal(5, 2)), 10, CAST(N'2024-08-12' AS Date), CAST(N'2024-11-08' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'6e903d6f-41f2-4464-99eb-be983b6a8f22', N'4a150c66-0c2b-4626-8e66-4035a87c1ab0', CAST(58004.83 AS Decimal(18, 2)), CAST(1.00 AS Decimal(5, 2)), 3, CAST(N'2024-08-12' AS Date), CAST(N'2024-05-18' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'71b30fa9-a5ed-4c82-8ffe-9dbeee1c8fd2', N'db0df896-914e-491f-9e31-454b9f1d3c7f', CAST(57309.59 AS Decimal(18, 2)), CAST(7.00 AS Decimal(5, 2)), 5, CAST(N'2024-10-17' AS Date), CAST(N'2025-02-13' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'78e63c69-f0fa-4bac-87fb-82da72841780', N'a23ae674-314f-4a4b-845a-ae0ff78d3512', CAST(57686.50 AS Decimal(18, 2)), CAST(6.00 AS Decimal(5, 2)), 5, CAST(N'2024-12-26' AS Date), CAST(N'2024-09-12' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'79b95262-c1ff-47ce-808f-5899b48f1557', N'27693ec7-45c9-4230-89d2-d0c98654cde7', CAST(54152.91 AS Decimal(18, 2)), CAST(19.00 AS Decimal(5, 2)), 2, CAST(N'2024-12-11' AS Date), CAST(N'2024-07-30' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'7a15a920-83d5-4aa4-a583-066e0c16fff1', N'6e360958-11c9-41fc-a89f-4238b8a0ae24', CAST(49434.10 AS Decimal(18, 2)), CAST(14.00 AS Decimal(5, 2)), 6, CAST(N'2025-02-01' AS Date), CAST(N'2025-03-11' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'7a1f9203-2b06-43c6-b126-c4be0af1654b', N'79dcf8ce-329d-48a8-ac2c-9fa869b4ac42', CAST(45512.95 AS Decimal(18, 2)), CAST(9.00 AS Decimal(5, 2)), 9, CAST(N'2024-08-07' AS Date), CAST(N'2024-12-16' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'7b2fb1af-2e95-4fbb-82dc-4bc8b895198f', N'43803350-bfb2-46b7-8949-24dc4b72fbf3', CAST(43625.99 AS Decimal(18, 2)), CAST(2.00 AS Decimal(5, 2)), 6, CAST(N'2024-10-07' AS Date), CAST(N'2024-10-18' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'7bb906f8-d2e0-44cd-a567-a153218e4ecf', N'5d8912f2-8074-4f41-b002-e0c789e7f718', CAST(45439.89 AS Decimal(18, 2)), CAST(23.00 AS Decimal(5, 2)), 2, CAST(N'2025-04-07' AS Date), CAST(N'2024-11-07' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'7daa4fe8-5771-4d3b-836e-e0ef0335e41b', N'6ae55628-7994-4e93-b964-f75e00363d72', CAST(42701.62 AS Decimal(18, 2)), CAST(9.00 AS Decimal(5, 2)), 7, CAST(N'2025-04-11' AS Date), CAST(N'2024-07-10' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'7dedfaa4-4f9f-4156-8433-22354b6a797e', N'23fd617f-9912-4a67-b5cb-60147b25930c', CAST(44964.94 AS Decimal(18, 2)), CAST(9.00 AS Decimal(5, 2)), 10, CAST(N'2024-09-10' AS Date), CAST(N'2024-12-01' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'81565b2e-2913-4553-a450-9af6b63e44fd', N'14f35ff7-5574-4e12-ad89-7e7704a02e62', CAST(62005.93 AS Decimal(18, 2)), CAST(20.00 AS Decimal(5, 2)), 4, CAST(N'2024-08-29' AS Date), CAST(N'2024-09-30' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'81f9f1e4-dcbe-436d-93d8-1e2735415e8d', N'85916c42-22cb-4462-9fa2-9c45feea827e', CAST(49040.35 AS Decimal(18, 2)), CAST(18.00 AS Decimal(5, 2)), 3, CAST(N'2024-05-05' AS Date), CAST(N'2024-04-29' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'832582ec-dde3-42a8-8ef4-2c327e9bec70', N'd933fcc1-a91f-4051-9cc1-58e1bf6be236', CAST(49489.72 AS Decimal(18, 2)), CAST(18.00 AS Decimal(5, 2)), 8, CAST(N'2025-04-14' AS Date), CAST(N'2025-03-28' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'83f7b4ce-7bb9-4f0b-92ff-abae672eff07', N'13aac759-5c49-42dc-9693-0f46cb1337bb', CAST(57013.89 AS Decimal(18, 2)), CAST(2.00 AS Decimal(5, 2)), 5, CAST(N'2024-09-26' AS Date), CAST(N'2025-01-29' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'845baeaa-ec87-463a-8e5e-7281c5c6082d', N'623e0b78-6b7c-4e98-a46a-c96d1c607817', CAST(57515.62 AS Decimal(18, 2)), CAST(1.00 AS Decimal(5, 2)), 3, CAST(N'2024-08-06' AS Date), CAST(N'2025-04-04' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'85c81a58-c3a8-4746-83dd-da8b38017524', N'3f5ab011-f526-4bbd-8ab8-8a67ad95c5bf', CAST(40906.87 AS Decimal(18, 2)), CAST(18.00 AS Decimal(5, 2)), 10, CAST(N'2025-04-20' AS Date), CAST(N'2025-02-10' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'861ce501-cb65-468b-81e8-5e80af214c9e', N'ba054855-8fa2-4f85-965a-6ba3b5fc13d3', CAST(47956.68 AS Decimal(18, 2)), CAST(2.00 AS Decimal(5, 2)), 10, CAST(N'2024-10-23' AS Date), CAST(N'2024-07-30' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'87956e86-0adc-4333-843a-3265297d3a2d', N'4837eb17-36bb-4c4b-bb49-bc368edb173a', CAST(44872.34 AS Decimal(18, 2)), CAST(5.00 AS Decimal(5, 2)), 1, CAST(N'2024-08-04' AS Date), CAST(N'2024-08-12' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'8b7a6cf4-e84a-44b5-9df3-a93efe7bc629', N'6ca0328f-1be0-4205-9a57-59cef27a1067', CAST(39558.32 AS Decimal(18, 2)), CAST(22.00 AS Decimal(5, 2)), 2, CAST(N'2025-01-20' AS Date), CAST(N'2025-02-10' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'8c0dca6a-41dd-4f6c-94b7-bedfe446dac3', N'1f2aa50e-b682-43da-b36e-f33d041691dc', CAST(47298.73 AS Decimal(18, 2)), CAST(13.00 AS Decimal(5, 2)), 1, CAST(N'2024-11-02' AS Date), CAST(N'2024-06-29' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'8c9c396c-7918-4e4f-b0a6-15a2b7315d7d', N'585b6bfa-e33a-4e75-8d2e-5cf1e4a42197', CAST(56792.76 AS Decimal(18, 2)), CAST(24.00 AS Decimal(5, 2)), 1, CAST(N'2024-07-30' AS Date), CAST(N'2024-04-29' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'9224cfe9-efaf-42b9-9195-1e0fa8d0d530', N'9253d6d7-b356-4e9e-8fa4-e60c1d0327cc', CAST(39563.92 AS Decimal(18, 2)), CAST(9.00 AS Decimal(5, 2)), 9, CAST(N'2025-04-23' AS Date), CAST(N'2024-09-20' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'957ae0b7-77a8-4c13-ae35-71679a57f31b', N'9da1cc29-9c8b-498c-bbbd-c412a8115cc8', CAST(42860.95 AS Decimal(18, 2)), CAST(15.00 AS Decimal(5, 2)), 8, CAST(N'2025-01-06' AS Date), CAST(N'2024-10-25' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'9648a2dc-58b8-4ad1-bb79-eb985d554cd7', N'ed4658f1-c11e-484a-b761-c911885548c2', CAST(50665.53 AS Decimal(18, 2)), CAST(23.00 AS Decimal(5, 2)), 4, CAST(N'2024-09-08' AS Date), CAST(N'2025-01-08' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'96d114bf-ef1c-483c-b3b1-b05b81debe30', N'a9de1fc5-3ba9-4088-8ee6-5a75104f2c7d', CAST(39573.93 AS Decimal(18, 2)), CAST(5.00 AS Decimal(5, 2)), 8, CAST(N'2024-10-31' AS Date), CAST(N'2024-12-20' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'998bd488-1f59-4950-bd8c-02a5efcef5f9', N'a34887df-cb28-4cab-a2ab-0f7de63719b9', CAST(42297.38 AS Decimal(18, 2)), CAST(22.00 AS Decimal(5, 2)), 9, CAST(N'2024-05-25' AS Date), CAST(N'2024-08-29' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'9c7970c7-2bb0-4156-ae2a-e6a7a826b150', N'ee6cebc9-6876-4561-9355-b84013639e66', CAST(49174.06 AS Decimal(18, 2)), CAST(23.00 AS Decimal(5, 2)), 9, CAST(N'2024-06-08' AS Date), CAST(N'2024-06-07' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'a1778f5e-d18c-4c98-a63e-49f4e56ee11f', N'fa5b05d5-cd6d-4e43-840d-4e368a1dac48', CAST(61818.54 AS Decimal(18, 2)), CAST(13.00 AS Decimal(5, 2)), 4, CAST(N'2025-04-10' AS Date), CAST(N'2024-10-22' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'a3790b99-7016-4e62-84ec-e7b2d4c29120', N'57829c08-247e-4dec-b528-cd1099fc1e81', CAST(52222.18 AS Decimal(18, 2)), CAST(11.00 AS Decimal(5, 2)), 10, CAST(N'2024-09-01' AS Date), CAST(N'2025-03-11' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'a9ae76f3-8548-4e44-9e13-fe8e21f6db0e', N'69514bb4-0f65-4e74-b29e-92b1febb7933', CAST(48132.41 AS Decimal(18, 2)), CAST(12.00 AS Decimal(5, 2)), 10, CAST(N'2024-10-16' AS Date), CAST(N'2024-05-26' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'aa1e5774-b153-4f7e-a325-b3c9f6918f34', N'e8a917b4-9641-4271-91a2-2a0ef3477c76', CAST(54828.95 AS Decimal(18, 2)), CAST(12.00 AS Decimal(5, 2)), 1, CAST(N'2024-08-03' AS Date), CAST(N'2025-03-08' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'aae20568-6f83-4d82-b88f-92d12e9aef78', N'6daa0a7c-3ca5-4ace-9d6c-b119d9067a6a', CAST(50183.96 AS Decimal(18, 2)), CAST(8.00 AS Decimal(5, 2)), 2, CAST(N'2024-07-25' AS Date), CAST(N'2024-07-04' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'b03c3409-5172-4dde-80a0-cc37cf999f56', N'b4a5aa8b-b1f2-478d-b60c-7efd3b198ee5', CAST(51625.68 AS Decimal(18, 2)), CAST(22.00 AS Decimal(5, 2)), 2, CAST(N'2024-08-21' AS Date), CAST(N'2024-06-26' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'b18802e8-45c0-496e-9311-cc74d19d64ca', N'93718b0c-9337-4efa-bd48-51713fb1523c', CAST(37898.70 AS Decimal(18, 2)), CAST(9.00 AS Decimal(5, 2)), 10, CAST(N'2024-09-01' AS Date), CAST(N'2024-07-10' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'b200a1fc-8010-426d-aa9c-ee6765979eae', N'86f4ec23-7064-4bb5-9aaf-b8e98e8d95ec', CAST(42420.67 AS Decimal(18, 2)), CAST(6.00 AS Decimal(5, 2)), 2, CAST(N'2024-11-21' AS Date), CAST(N'2025-04-01' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'b4c184b2-9da1-41ff-96a5-de7f8c27f376', N'7f18c59c-3e61-43f6-946f-d0b81fbd3cc7', CAST(41749.75 AS Decimal(18, 2)), CAST(19.00 AS Decimal(5, 2)), 8, CAST(N'2024-10-26' AS Date), CAST(N'2024-09-20' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'b539f60d-b4f0-496d-8489-f0d2adefdfdb', N'f8628b73-c900-4973-849e-22aa8e42fc33', CAST(47222.64 AS Decimal(18, 2)), CAST(23.00 AS Decimal(5, 2)), 9, CAST(N'2024-11-08' AS Date), CAST(N'2024-07-05' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'bd705e81-a813-4efd-b0b4-6f170a45a630', N'd01d990c-8cbd-4b0f-87b3-4c31fafbf3d5', CAST(59122.45 AS Decimal(18, 2)), CAST(0.00 AS Decimal(5, 2)), 2, CAST(N'2024-07-15' AS Date), CAST(N'2024-10-24' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'bf22a5f0-efd7-4b45-aa7b-f7dcc5820029', N'9d78736f-df51-4622-9cb1-c4db88dca2d0', CAST(52464.68 AS Decimal(18, 2)), CAST(19.00 AS Decimal(5, 2)), 7, CAST(N'2024-09-01' AS Date), CAST(N'2024-10-17' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'c3151876-a408-427e-bb81-4ff51ced5156', N'5c41586b-f7bf-41fa-883a-7b9cb1c4c849', CAST(53267.88 AS Decimal(18, 2)), CAST(14.00 AS Decimal(5, 2)), 9, CAST(N'2025-03-26' AS Date), CAST(N'2024-12-26' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'c3b4c3b8-0511-481d-bf7f-5da93c8014df', N'6b7b3dfa-9959-401f-9b8c-fce6948abc45', CAST(47811.49 AS Decimal(18, 2)), CAST(15.00 AS Decimal(5, 2)), 5, CAST(N'2024-06-02' AS Date), CAST(N'2025-04-01' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'c3c5f705-4968-433b-8ee6-5223d34db242', N'f40f3b32-6b03-4f88-896a-949bb777a247', CAST(44959.63 AS Decimal(18, 2)), CAST(22.00 AS Decimal(5, 2)), 8, CAST(N'2024-12-04' AS Date), CAST(N'2024-07-18' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'c3cee2e0-f41e-4b74-a093-d2aaae9b9125', N'cd125a77-15a1-4c04-aaed-41a05195225b', CAST(39437.29 AS Decimal(18, 2)), CAST(8.00 AS Decimal(5, 2)), 5, CAST(N'2025-02-24' AS Date), CAST(N'2024-12-23' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'c6709969-de1b-4d20-972e-ee492ba2d639', N'1f72084e-90f3-4334-9b8f-a3b350c2beb0', CAST(50908.28 AS Decimal(18, 2)), CAST(5.00 AS Decimal(5, 2)), 2, CAST(N'2024-11-07' AS Date), CAST(N'2024-05-30' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'ca3651a5-a4e3-41d9-b104-14a2fef95624', N'b9779359-2984-4b3a-83cd-0e0eab80293c', CAST(40994.85 AS Decimal(18, 2)), CAST(14.00 AS Decimal(5, 2)), 7, CAST(N'2024-10-03' AS Date), CAST(N'2025-01-17' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'cf7dc393-b7f1-4bb7-8178-d5336f3759af', N'357e3969-87b3-48e9-bd0b-4a658de0dd38', CAST(57046.44 AS Decimal(18, 2)), CAST(16.00 AS Decimal(5, 2)), 7, CAST(N'2024-12-01' AS Date), CAST(N'2024-05-17' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'd2528160-fa7c-4d82-9b3c-d8423b8fd849', N'9e5061d8-a27f-44cc-a390-5f9ab4d00178', CAST(42521.13 AS Decimal(18, 2)), CAST(19.00 AS Decimal(5, 2)), 1, CAST(N'2024-06-11' AS Date), CAST(N'2025-04-23' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'd4fc550f-438a-4d1c-9e77-cd42f6d56b00', N'6a9b75fb-c1c5-4e1a-a94e-07cbb5c41837', CAST(56166.06 AS Decimal(18, 2)), CAST(20.00 AS Decimal(5, 2)), 5, CAST(N'2024-09-03' AS Date), CAST(N'2025-01-09' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'dc97911c-01e9-4034-8abb-61e497e97123', N'3a57a285-56e7-4900-bc63-d044f2247ff1', CAST(51620.33 AS Decimal(18, 2)), CAST(11.00 AS Decimal(5, 2)), 11, CAST(N'2024-08-25' AS Date), CAST(N'2024-10-12' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'e23f6da4-f038-48b0-9fe7-798662be1d4a', N'50acac78-1c19-491e-8e95-2787664d9090', CAST(45429.97 AS Decimal(18, 2)), CAST(6.00 AS Decimal(5, 2)), 4, CAST(N'2024-11-01' AS Date), CAST(N'2024-10-06' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'e4134aea-92ef-4bc2-b75d-73acd760fd18', N'a99c66ac-ae2a-4375-b15c-9b1694200e6d', CAST(49258.79 AS Decimal(18, 2)), CAST(10.00 AS Decimal(5, 2)), 6, CAST(N'2024-09-09' AS Date), CAST(N'2024-07-05' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'e88e3cad-b274-474b-96a0-fa7f9e5effa1', N'6f6a46c1-26ae-47c8-82aa-34027c84af78', CAST(43111.80 AS Decimal(18, 2)), CAST(3.00 AS Decimal(5, 2)), 3, CAST(N'2024-11-04' AS Date), CAST(N'2024-08-04' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'e89e4746-a369-4daa-bb68-2c395b052b81', N'0bedb8d0-0c5a-48a9-bae1-5b1fbecf4a10', CAST(49337.83 AS Decimal(18, 2)), CAST(13.00 AS Decimal(5, 2)), 6, CAST(N'2024-12-10' AS Date), CAST(N'2024-11-16' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'e99783ae-b59e-48e8-826e-56fbd31b9a10', N'61ac2df4-4e87-4f00-af98-a9c55edbdd80', CAST(47256.40 AS Decimal(18, 2)), CAST(14.00 AS Decimal(5, 2)), 6, CAST(N'2025-04-16' AS Date), CAST(N'2024-07-01' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'ea666568-ab56-4b00-a0e4-c2f89a858df3', N'fd29af21-54cd-42a1-a4d7-40890f6dd658', CAST(51878.06 AS Decimal(18, 2)), CAST(13.00 AS Decimal(5, 2)), 3, CAST(N'2025-04-21' AS Date), CAST(N'2024-10-19' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'ecbb25c9-6d69-4f0b-a65a-ec0cb8cbe705', N'3701903e-265f-402d-b8f9-5e46a67a89a6', CAST(42893.18 AS Decimal(18, 2)), CAST(0.00 AS Decimal(5, 2)), 10, CAST(N'2024-08-18' AS Date), CAST(N'2025-01-03' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'ed24ba66-305a-437f-aa86-efb51bb39402', N'daf898aa-13cd-465a-b2ed-ce3605ff9cc2', CAST(49946.08 AS Decimal(18, 2)), CAST(2.00 AS Decimal(5, 2)), 2, CAST(N'2024-12-22' AS Date), CAST(N'2024-12-03' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'f1750929-37d5-40f5-a9bd-6bd2c20aff8c', N'6b612ed4-f731-4963-85f3-780a438e0fad', CAST(40841.94 AS Decimal(18, 2)), CAST(4.00 AS Decimal(5, 2)), 10, CAST(N'2024-12-20' AS Date), CAST(N'2024-06-05' AS Date), N'defaulted')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'f92cf2be-1c0e-4a5c-80f2-34f69c051450', N'a424f2b5-0890-4fc1-a71e-9ea7547a5a25', CAST(54974.14 AS Decimal(18, 2)), CAST(2.00 AS Decimal(5, 2)), 10, CAST(N'2024-05-14' AS Date), CAST(N'2025-03-25' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'fab66d90-8053-4709-bf4d-dfc18ddee625', N'5b3fb023-fd43-4cae-8783-ef1c98d11b38', CAST(49001.01 AS Decimal(18, 2)), CAST(13.00 AS Decimal(5, 2)), 8, CAST(N'2024-11-20' AS Date), CAST(N'2025-01-03' AS Date), N'closed')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'fac5069a-d2f1-4613-b0e6-542fd42a941f', N'abd49d49-237d-4d28-b3ea-9d19661fcf9b', CAST(56930.24 AS Decimal(18, 2)), CAST(8.00 AS Decimal(5, 2)), 8, CAST(N'2025-04-04' AS Date), CAST(N'2024-08-31' AS Date), N'active')
INSERT [dbo].[loans] ([loan_id], [customer_id], [loan_amount], [interest_rate], [loan_terms_months], [start_date], [end_date], [status]) VALUES (N'fdfae8c8-41a9-4eb8-88fd-8d23ed96c85e', N'43776145-9002-47aa-a868-c0ca95951f5b', CAST(44057.78 AS Decimal(18, 2)), CAST(24.00 AS Decimal(5, 2)), 2, CAST(N'2024-07-14' AS Date), CAST(N'2024-10-07' AS Date), N'defaulted')
GO
INSERT [dbo].[transaction_types] ([transaction_type_id], [name]) VALUES (1, N'Deposit')
INSERT [dbo].[transaction_types] ([transaction_type_id], [name]) VALUES (2, N'Transfer')
INSERT [dbo].[transaction_types] ([transaction_type_id], [name]) VALUES (3, N'Withdrawal')
GO
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'0096cba5-4e9c-49f4-b1df-4955a76275e4', N'802b2efe-e1d1-465b-940f-5cf573a2c985', 2, CAST(80.72 AS Decimal(18, 2)), CAST(N'2024-10-17T00:06:59.000' AS DateTime), N'Potest fieri quanta ad augendas cum conscientia fa', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'01e6c965-00a0-41c8-8fc6-320a25e171e2', N'f75c87e7-70a8-4fbd-8ad6-9d5e9cefc314', 2, CAST(112.54 AS Decimal(18, 2)), CAST(N'2025-01-21T12:01:19.000' AS DateTime), N'Integris testibus si infantes pueri mutae etiam be', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'027c8cc4-d92d-46cd-8256-d46f395f3e0c', N'd29c5b3d-6bb3-4248-bf1a-4339bc80b6b0', 1, CAST(112.34 AS Decimal(18, 2)), CAST(N'2024-07-18T13:04:35.000' AS DateTime), N'Ficta pueriliter tum ne efficit quidem quod vult N', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'049519be-3725-44ee-bf7e-f71ea192625e', N'f9341b55-2686-40af-9e1b-2986672efd92', 1, CAST(89.76 AS Decimal(18, 2)), CAST(N'2025-02-06T03:42:17.000' AS DateTime), N'Beateque vivendo a Platone disputata sunt haec', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'04e45e65-b269-4c95-9362-74e17a8319bf', N'6edc13ce-6ed2-48a7-b73d-ef6ed8b73e38', 3, CAST(76.99 AS Decimal(18, 2)), CAST(N'2024-08-04T12:28:58.000' AS DateTime), N'Accedis saluto ''chaere'' inquam ''Tite'' lictores tur', N'4734b927-4bba-4591-a8fc-caf19a15faed')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'063e014a-839b-4ed2-b3a3-510e528f961c', N'0937445f-d5eb-4ef9-887f-4173fe662dd4', 1, CAST(122.10 AS Decimal(18, 2)), CAST(N'2025-03-05T00:22:17.000' AS DateTime), N'Et quidem locis pluribus', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'06ae34b6-1723-4b44-baf9-a885f489f723', N'71c0f7ab-b701-45f0-9c94-802383b3cc36', 1, CAST(87.25 AS Decimal(18, 2)), CAST(N'2025-01-09T09:05:38.000' AS DateTime), N'Quales eius maiores fuissent et in conspectum suum', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'0db669d2-610c-44cd-b5fa-2e3f58051d09', N'c098f0dd-6434-4f69-afdd-d756849fe1fd', 1, CAST(124.05 AS Decimal(18, 2)), CAST(N'2024-08-28T00:48:45.000' AS DateTime), N'Praeterea neque praesenti nec', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'0e5ccf7d-0803-476b-8405-23e0b5091c08', N'd094e634-9744-478d-b73b-1a73149b198b', 2, CAST(98.25 AS Decimal(18, 2)), CAST(N'2024-06-29T15:41:58.000' AS DateTime), N'Fidem sensibus confirmat id est in eo quod semel a', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'117e659a-c474-4cab-87a4-a5f902fc6453', N'2fdf706a-7187-470c-a1c3-f3e747b72f20', 3, CAST(110.02 AS Decimal(18, 2)), CAST(N'2024-09-17T22:54:11.000' AS DateTime), N'Dolores eos qui ratione voluptatem sequi nesciunt ', N'20b7e7f8-4bb9-4efa-b6bf-c25b7bd921e2')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'11baa8a7-a180-47b0-9fed-583129ee66a0', N'15b082e5-92e7-4375-a7d9-f7224d35ba13', 3, CAST(101.20 AS Decimal(18, 2)), CAST(N'2024-06-28T01:14:58.000' AS DateTime), N'Sit voluptatem accusantium doloremque laudantium t', N'd5d0aabf-62b8-416f-88dc-3546b47a13de')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'1229a502-c09e-478b-9939-4f7599344d37', N'eae2bb46-3bd9-4bd6-a6b7-1b2efdc1911a', 3, CAST(111.00 AS Decimal(18, 2)), CAST(N'2025-02-11T21:11:29.000' AS DateTime), N'Spe proposita fore levius aliquando nulla praetere', N'1679f7d5-3d24-45eb-a146-72c35e80dbe3')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'12d27a78-cec9-4eba-b6b2-691e9291d977', N'45d4aa3e-cee4-431f-ac63-f83e4c56e862', 3, CAST(120.66 AS Decimal(18, 2)), CAST(N'2025-02-16T15:16:49.000' AS DateTime), N'Frustra se aut pecuniae studuisse aut imperiis aut', N'e837a350-66bc-4169-91b3-687ffc3e150e')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'13706eb5-aabb-467b-86ca-b1c9999dc7dc', N'57620a31-a1ee-4dbc-9a72-09bc5bb72b7d', 2, CAST(96.05 AS Decimal(18, 2)), CAST(N'2024-11-23T23:08:47.000' AS DateTime), N'Non offendit nam et laetamur amicorum laetitia', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'14d252e4-30ea-473f-87cd-16d00e4e7415', N'1afc36b6-ae72-48ff-9d51-5f57fac653bc', 3, CAST(121.22 AS Decimal(18, 2)), CAST(N'2025-03-25T15:05:42.000' AS DateTime), N'Qua intellegebat contineri suam Atque haec ratio l', N'd494f351-9ecd-4c50-a7b0-57586ba55764')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'1800E6CB-A4DE-4E0D-8436-AF010D8EF63B', N'905660c8-d6a7-40e9-9be3-e6711d22efb6', 1, CAST(500.00 AS Decimal(18, 2)), CAST(N'2025-05-22T14:35:16.850' AS DateTime), N'Transfer received from account 9cd97ecb-58c9-4610-', N'9cd97ecb-58c9-4610-b4b1-d9f72bcae7f7')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'189574d3-bf80-449b-a8e6-e0ef42d0a096', N'3f494e04-a406-4692-a584-19db622e48ac', 2, CAST(123.90 AS Decimal(18, 2)), CAST(N'2025-03-13T07:48:13.000' AS DateTime), N'Id ne ferae quidem faciunt ut ita dicam et ad corp', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'1bc0bec8-97de-4720-8278-a18d7538c308', N'a448f319-9dc4-4c02-b016-e1eab2b49629', 2, CAST(91.54 AS Decimal(18, 2)), CAST(N'2024-08-16T04:51:30.000' AS DateTime), N'Bonorum quod omnium philosophorum sententia tale d', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'1d7d4fab-9ae3-47a5-a276-c85e413e7791', N'40ede99d-89ee-49c9-b1f9-de9b0e61ff33', 3, CAST(112.80 AS Decimal(18, 2)), CAST(N'2024-09-27T00:38:09.000' AS DateTime), N'Se oratio tua praesertim qui studiose antiqua pers', N'afa23ea5-304f-4610-872b-a62bc0c8dd0c')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'1ddf4572-0fe2-4535-9314-e968921dd07d', N'73b13073-025d-45c9-bed2-6b6760e7e10d', 1, CAST(79.39 AS Decimal(18, 2)), CAST(N'2024-07-06T17:41:05.000' AS DateTime), N'Solemus quanto id in hominum consuetudine facilius', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'21b5a0dc-c54e-47f7-b465-0e4ab4797405', N'e0c672fd-8182-42b1-8a70-2138f223c47c', 3, CAST(114.17 AS Decimal(18, 2)), CAST(N'2024-09-20T20:20:26.000' AS DateTime), N'Quo voluptas nulla pariatur At vero eos et accusam', N'dbd9bc1c-90b0-44b7-b612-b16d0e1f96f7')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'241b055f-5955-4fb1-9ed8-ce96860e941a', N'8d7d7e4b-11a9-47e3-bca0-8f3aa0bada73', 1, CAST(103.46 AS Decimal(18, 2)), CAST(N'2024-11-03T08:57:00.000' AS DateTime), N'Quae quasi saxum Tantalo semper impendet tum super', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'25b8e31e-a320-4a32-b2a5-08920b77f3ad', N'4adb1b7b-163e-4a1b-956f-9a3fa65d8b70', 3, CAST(87.81 AS Decimal(18, 2)), CAST(N'2024-08-09T23:13:21.000' AS DateTime), N'Animo', N'e0972767-3ae3-41ee-b8e5-cf3e42f852e2')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'2a9f2378-3ac8-4eb3-b801-5656cd2bf91f', N'36f3d280-2886-4e51-adcd-dfc644e59d80', 1, CAST(119.26 AS Decimal(18, 2)), CAST(N'2024-12-08T18:06:48.000' AS DateTime), N'Loco videtur quibusdam stabilitas amicitiae vacill', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'2ae8fb1c-1844-4602-aa0a-5a13a6507874', N'ac35eddd-0fb1-4711-9bb8-1985fc566b52', 2, CAST(79.15 AS Decimal(18, 2)), CAST(N'2024-06-24T10:22:24.000' AS DateTime), N'Nisi te quoquo modo loqueretur intellegere', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'2b3b1663-f993-4e82-9dbe-7a7779e4648d', N'fe716f26-3b0e-4fe5-bc40-4663f4fa66c0', 1, CAST(124.22 AS Decimal(18, 2)), CAST(N'2024-12-29T22:49:39.000' AS DateTime), N'Intemperantes et ignavi numquam in sententia perma', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'2bc5a3aa-b92a-4384-a83d-e6f6c8ba182a', N'54c49a0b-5dc6-46f8-abf2-ed2d1e56da8c', 3, CAST(120.37 AS Decimal(18, 2)), CAST(N'2024-07-17T02:33:59.000' AS DateTime), N'Celeritas diuturnitatem allevatio consoletur Ad ea', N'88689d1f-ceda-4e0d-b601-915af09fb32a')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'3322a905-6f9a-4460-8c68-d8ce45feffaa', N'748ace76-6b8a-4fd4-9de1-b6154ce22189', 1, CAST(102.26 AS Decimal(18, 2)), CAST(N'2024-09-21T08:52:41.000' AS DateTime), N'Everti si ita melius sit migrare de vita His rebus', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'34608f20-08ad-42b2-8ac9-6a450b4788b9', N'c73f146f-aef6-415f-bc17-8bf06ba9819e', 2, CAST(86.91 AS Decimal(18, 2)), CAST(N'2024-11-15T04:57:54.000' AS DateTime), N'Nisi nescio quam illam umbram quod appellant hones', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'39ee7d32-a3ca-455c-9aa2-8e6fedde2f39', N'ce49f4c7-302b-4d63-b068-8f01fd6e28a7', 3, CAST(99.29 AS Decimal(18, 2)), CAST(N'2024-11-08T01:15:22.000' AS DateTime), N'Qua etiam carere possent sine dolore tum in dedeco', N'e4f2afd7-cd26-4325-a253-7aed34920158')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'3f30d441-419d-4b4c-ae6a-8528cba6862c', N'5d8f91d2-881d-46c9-9d1f-19d33516897f', 2, CAST(112.03 AS Decimal(18, 2)), CAST(N'2025-01-17T11:08:16.000' AS DateTime), N'Doloribus quanti in hominem maximi cadere possunt ', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'415591cc-b2b2-412a-8798-20b0269bfb20', N'd6a1328a-055b-40f3-9c71-da27fec396d2', 1, CAST(122.17 AS Decimal(18, 2)), CAST(N'2024-06-19T14:28:05.000' AS DateTime), N'Contemnit qua qui utuntur benivolentiam sibi conci', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'423a25c8-aeb3-4823-95be-99f6a213d9bc', N'418fedb1-da8f-4c67-8073-4a147e2f5ded', 1, CAST(111.13 AS Decimal(18, 2)), CAST(N'2024-05-23T13:36:37.000' AS DateTime), N'Dicant foedus esse quoddam sapientium ut ne minus ', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'42AF83B0-54C5-4656-8913-80AF8882E178', N'9cd97ecb-58c9-4610-b4b1-d9f72bcae7f7', 2, CAST(500.00 AS Decimal(18, 2)), CAST(N'2025-05-22T14:35:16.840' AS DateTime), N'Transfer ke akun lain', N'905660c8-d6a7-40e9-9be3-e6711d22efb6')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'488f3a0c-a01c-4e6d-a46a-c9d4b04620f0', N'441aa9d2-bdf2-4b65-a79f-c18e66de0e17', 2, CAST(116.77 AS Decimal(18, 2)), CAST(N'2024-06-19T00:28:51.000' AS DateTime), N'Latinam linguam non modo quid nobis probaretur sed', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'4c67ca98-65ab-486d-a48a-1dadd2bc365b', N'96da7988-0695-4780-a7c3-6c935daccc59', 1, CAST(121.47 AS Decimal(18, 2)), CAST(N'2025-01-03T07:55:40.000' AS DateTime), N'Se nobis ducem praebeat ad voluptatem', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'4f6655d6-789d-477f-b61b-63acb94a1604', N'c8a710b1-6302-4189-8149-da76be7fdfc1', 1, CAST(79.94 AS Decimal(18, 2)), CAST(N'2024-09-20T22:52:04.000' AS DateTime), N'Sit numeranda nec in discordia dominorum domus quo', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'50c0a6f3-faba-4031-bb3b-e30a1bab1c5c', N'da3b43bc-55d1-4f0b-80d1-494ccfc9acc5', 2, CAST(102.44 AS Decimal(18, 2)), CAST(N'2025-03-22T10:19:47.000' AS DateTime), N'Cum ita esset affecta secundum non recte si volupt', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'541f3e47-8c96-48d0-a61c-32e238e3ab14', N'318c43bf-9511-4030-bd13-81a47a4b8cac', 3, CAST(79.45 AS Decimal(18, 2)), CAST(N'2024-06-20T18:02:31.000' AS DateTime), N'Nihil nisi praesens et quod quaeritur saepe cur ta', N'1f60f3f4-81b4-4f88-9f8e-e352e30351e9')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'54efc385-e6b7-4ce4-9be8-f2cc29398d38', N'bff8f8bd-3931-4f3f-b0c1-636597f97db5', 2, CAST(118.34 AS Decimal(18, 2)), CAST(N'2025-01-22T11:55:29.000' AS DateTime), N'Iustitiam quidem recte quis dixerit per se ipsa al', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'583ebd92-6330-47e2-9115-c590b51238c9', N'92ffabae-dab4-4737-8b26-ee60ed598cea', 2, CAST(81.82 AS Decimal(18, 2)), CAST(N'2025-03-08T05:03:38.000' AS DateTime), N'Obruamus et secunda iucunde', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'5b01a515-b320-4411-bc4d-03057bc38c7d', N'17a9ed0a-5ed3-41d6-9e20-df434296c83d', 2, CAST(79.90 AS Decimal(18, 2)), CAST(N'2025-03-10T08:51:11.000' AS DateTime), N'Postea variari voluptas distinguique possit augeri', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'5ca3ef09-7b18-4782-a38a-9a621f898b19', N'65b4514d-4bbb-4aed-b0e0-859e1bef135e', 2, CAST(118.80 AS Decimal(18, 2)), CAST(N'2024-05-20T17:39:54.000' AS DateTime), N'-- Filium morte multavit ', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'67648c15-25f2-4bb7-b7ed-9fb60f3b2d08', N'89a22c8c-57ba-4baa-8b71-13d1210a62d6', 3, CAST(110.92 AS Decimal(18, 2)), CAST(N'2024-12-25T22:44:11.000' AS DateTime), N'Quod semel admissum coerceri reprimique non potest', N'3b525f55-42f1-400a-aeea-8d4422f096ca')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'693b5625-5527-43c2-9645-0e172faea12f', N'34e9be76-4674-4d0f-b7c0-a39e43548747', 3, CAST(77.12 AS Decimal(18, 2)), CAST(N'2025-01-26T00:17:49.000' AS DateTime), N'Ipsa quae qualisque sit ut tollatur error omnis im', N'f979d2d7-863e-448b-a0e8-3ea8d7bc7f9b')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'6cf419fa-5d63-418a-83b7-346df8331ca6', N'80c28cdf-f2fb-4232-bbd5-39404d8199c2', 1, CAST(110.56 AS Decimal(18, 2)), CAST(N'2024-07-23T22:00:22.000' AS DateTime), N'Quamquam autem et praeterita grate meminit et prae', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'6d77ba74-b395-42c0-8e1a-0678bc4ca127', N'a9eb22fe-d2a1-4f58-b903-ba06bfab92c4', 2, CAST(79.35 AS Decimal(18, 2)), CAST(N'2024-10-30T13:18:45.000' AS DateTime), N'Magna aliqua Ut enim ad minima veniam quis nostrud', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'730f46e7-0a12-4bae-a34d-2c1893ece2ce', N'bf4afaa6-c52c-4b4e-b7f8-543eeb1ec49c', 2, CAST(109.34 AS Decimal(18, 2)), CAST(N'2024-10-20T04:34:34.000' AS DateTime), N'Quis dixerit per se laetitiam id est', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'7B777A53-4ECA-48B2-8FEF-210FAE6B2F79', N'9cd97ecb-58c9-4610-b4b1-d9f72bcae7f7', 1, CAST(1000.00 AS Decimal(18, 2)), CAST(N'2025-05-22T14:18:32.250' AS DateTime), N'Pembayaran Tagihan', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'7c819ea2-da8d-4590-932e-de0037e89802', N'1118a259-aa7d-402b-9f1f-72555ed15180', 2, CAST(93.12 AS Decimal(18, 2)), CAST(N'2024-12-01T20:04:29.000' AS DateTime), N'Nos amice et benivole collegisti nec me tamen laud', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'7d332d97-04e9-4737-8676-7b78dc39c96a', N'789de9f0-5ef0-46cc-bb19-fbe4928474e6', 3, CAST(102.24 AS Decimal(18, 2)), CAST(N'2024-11-17T16:47:48.000' AS DateTime), N'Ostendit iudicia rerum dirigentur numquam ullius o', N'8a392a96-c559-469b-835e-4a45c4ba85b8')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'80e62bc1-cb02-4c9d-bada-9dd4aa0cae3f', N'c50f01a9-441b-4a71-81c8-9f2a78288a92', 3, CAST(104.78 AS Decimal(18, 2)), CAST(N'2024-08-05T16:26:55.000' AS DateTime), N'Repudiandae sint et molestiae non recusandae Itaqu', N'b6bba53f-da2c-4770-bb3b-ed63c51bf5bf')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'82353c8f-c4ec-4e51-97d5-60101464a8fe', N'58e3e8fa-7549-4390-821e-d643a13d9c36', 2, CAST(121.39 AS Decimal(18, 2)), CAST(N'2024-11-30T05:45:24.000' AS DateTime), N'Loco videtur quibusdam stabilitas amicitiae vacill', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'82aeeaef-d879-49bf-8e37-8f41702623f5', N'1d97bce1-5c94-49e4-8e2a-6ad56b99afb0', 1, CAST(88.98 AS Decimal(18, 2)), CAST(N'2025-02-04T05:18:22.000' AS DateTime), N'Sibi quibus non solum praesentibus fruuntur sed et', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'82f54048-1086-4a91-b397-22a982e13fc2', N'ed508747-a9a1-432c-980f-388a4be8398d', 3, CAST(115.56 AS Decimal(18, 2)), CAST(N'2025-04-10T01:52:55.000' AS DateTime), N'Quodsi qui satis sibi contra hominum conscientiam ', N'6497ea37-1f6d-4d19-bf8b-8f0ff63bba73')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'87d27da1-f363-47d2-a2f6-f30b097e8c39', N'39e495d4-8be7-45fa-aab6-1ee6312cdd04', 1, CAST(102.76 AS Decimal(18, 2)), CAST(N'2024-10-18T05:39:14.000' AS DateTime), N'Vacillare tuentur tamen eum locum seque facile ut ', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'8bbc7aa9-8321-4adc-bb71-c2a088cf766d', N'535ff8ea-7b01-48a3-93a3-27288067830c', 1, CAST(122.97 AS Decimal(18, 2)), CAST(N'2024-09-03T00:44:10.000' AS DateTime), N'Investigandi veri nisi inveneris et quaerendi defa', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'8c805bd7-7ed0-4af0-818c-459cebd8fd7d', N'45ff6d75-3e4b-43ab-9343-ba2e0de1069a', 1, CAST(100.01 AS Decimal(18, 2)), CAST(N'2024-08-11T04:00:55.000' AS DateTime), N'Eiusmod tempor incididunt ut labore et dolore disp', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'8d379ad0-9f64-4e6c-b197-b4aa107d8a47', N'5ccb459e-6c87-432b-a742-c6c7cbf0dae3', 1, CAST(113.36 AS Decimal(18, 2)), CAST(N'2024-12-02T05:14:20.000' AS DateTime), N'Ipsius honestatis', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'8d8b7260-6fb6-427e-89df-b6ec53ab0eb8', N'bc45041a-05a7-4c9e-a2c0-324829aaca62', 3, CAST(87.23 AS Decimal(18, 2)), CAST(N'2024-05-12T05:03:34.000' AS DateTime), N'In amicitia et amicitia cum voluptate vivatur Quon', N'7cd31994-73e0-44b6-acc3-455185580d97')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'9050e88e-0079-43f1-9b81-e032727d8307', N'be1f9370-375a-4d20-bf0d-284e833ff113', 1, CAST(116.13 AS Decimal(18, 2)), CAST(N'2024-05-23T18:12:34.000' AS DateTime), N'Sabinum municipem Ponti Tritani centurionum praecl', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'9143af85-5ffc-4704-bab4-61e9817ee2cc', N'14f24b1b-6e86-4cb3-bbc4-0293bc90f756', 3, CAST(115.39 AS Decimal(18, 2)), CAST(N'2024-07-17T08:38:39.000' AS DateTime), N'Aut venandi consuetudine adamare solemus quanto id', N'ece0c0c4-66a9-4fcc-b2b0-f07d3414dbf4')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'9213c9fb-b67b-447d-a6ab-a078c6f0aa9b', N'b2b1797e-b848-4af5-8a52-2e4d66a5af90', 3, CAST(117.92 AS Decimal(18, 2)), CAST(N'2024-06-11T12:04:03.000' AS DateTime), N'Non satisfacit Te enim iudicem aequum puto modo qu', N'a560b9df-14e8-4084-86c8-34d12b25e2f6')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'92cf1981-8c89-452a-8112-7759fe8e895e', N'70b25eda-9b65-489a-b3b5-1b7650795fbd', 3, CAST(86.25 AS Decimal(18, 2)), CAST(N'2024-05-04T11:48:29.000' AS DateTime), N'In nobis ut et adversa quasi perpetua oblivione ob', N'8935d817-99dc-440a-9ef0-27b13711c02d')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'94e1cb50-85ae-4534-b217-f5f8b4c768c7', N'3a6e7b4a-c8db-4750-bbbc-a337ef92efe4', 1, CAST(105.05 AS Decimal(18, 2)), CAST(N'2024-11-07T15:41:37.000' AS DateTime), N'Desistunt', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'96b3156b-f834-486c-86df-76dd333a9e8c', N'980c1a90-3d66-4010-81c8-32cde239d423', 1, CAST(107.24 AS Decimal(18, 2)), CAST(N'2024-09-12T05:37:52.000' AS DateTime), N'Se aut pecuniae studuisse aut imperiis aut opibus ', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'97133932-d8e3-4f5d-9151-0fd5d52caa1a', N'4aab87c4-eb74-4e4e-ab8f-c13638276de1', 2, CAST(75.47 AS Decimal(18, 2)), CAST(N'2025-02-15T20:13:20.000' AS DateTime), N'Pecuniae studuisse aut imperiis aut opibus aut glo', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'97eec2d8-5c98-4962-b94b-0687e120668c', N'68c0a815-9332-4453-8a91-5ce066bb07e2', 3, CAST(94.46 AS Decimal(18, 2)), CAST(N'2024-10-06T15:44:25.000' AS DateTime), N'Praeterea et appetendi et refugiendi et omnino rer', N'b9dbd5ee-1f02-42d2-9b40-56c07ea71ef5')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'9a14b28f-e0ae-413f-bda7-1aaca6d8ede2', N'2156bbb2-c082-45e5-a5d6-f66752c37690', 2, CAST(79.94 AS Decimal(18, 2)), CAST(N'2024-10-15T11:45:09.000' AS DateTime), N'Philosophis compluribus permulta dicantur cur nec ', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'9aad011b-96d4-497c-85f8-2f26c14e897a', N'309d1066-7bcf-4772-9c5f-16aff605512e', 2, CAST(111.11 AS Decimal(18, 2)), CAST(N'2025-03-27T18:45:28.000' AS DateTime), N'Nostris et scribentur fortasse plura si vita suppe', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'9ac8ef96-6df7-43c6-8438-af7b90bb2fef', N'c49c54f1-1926-4cbb-b3f2-2299152dce3a', 3, CAST(124.08 AS Decimal(18, 2)), CAST(N'2024-12-10T04:51:59.000' AS DateTime), N'Certe non probes eum quem ego arbitror unum vidiss', N'16c6d4bc-4442-4e86-bd7c-45fc422cbccd')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'9d76822f-4714-4d47-86c7-4b5041dcc239', N'8c46fae1-9789-4427-8440-7cf48a0272cd', 2, CAST(120.54 AS Decimal(18, 2)), CAST(N'2025-03-31T17:45:05.000' AS DateTime), N'Posse iucunde vivi nisi sapienter honeste iusteque', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'a18aac72-4877-42a2-a6d7-5a82d063758d', N'b28eca06-abd3-43b5-b602-37bca09a6116', 2, CAST(102.54 AS Decimal(18, 2)), CAST(N'2024-08-25T11:46:18.000' AS DateTime), N'Tranquillat animos', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'a71ab662-caf1-43a6-ad8e-77831fcc73d4', N'4fae08d1-3301-4031-a7d5-1b6eac9a2bdd', 3, CAST(86.12 AS Decimal(18, 2)), CAST(N'2024-10-05T22:33:31.000' AS DateTime), N'Maxime hoc placeat moderatius tamen id volunt fier', N'e64868fa-d343-44c8-a2db-b67719b44f2f')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'a793a091-aa5f-41a6-b817-ee7b776ff995', N'4d499ecc-5bee-4104-a1b0-32ceff979305', 3, CAST(104.44 AS Decimal(18, 2)), CAST(N'2024-05-23T21:53:17.000' AS DateTime), N'Consectetur adipisci velit sed quia non numquam ei', N'2119aead-e31b-439d-ab73-845beeda0093')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'a8852322-eff1-4275-beb9-4c503043ddc0', N'71de6c84-d689-4792-b730-7711deb2a408', 2, CAST(77.20 AS Decimal(18, 2)), CAST(N'2025-01-30T23:15:26.000' AS DateTime), N'Gaudemus omne autem id quo gaudemus voluptas est u', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'ab0ac1a6-c84b-4606-ad92-00d7cae98ce7', N'dfd76a72-6dbc-4b94-a856-b77dd59d3b4a', 3, CAST(93.45 AS Decimal(18, 2)), CAST(N'2024-05-31T16:49:27.000' AS DateTime), N'Ea solum incommoda quae eveniunt', N'd4f72e06-e6ca-47ac-894f-613a57c18425')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'adfa8723-3735-4ff2-8428-90bdd84413c7', N'7b1fccd6-d4ab-4f58-9ae1-b45947264b33', 3, CAST(104.21 AS Decimal(18, 2)), CAST(N'2024-10-06T11:15:58.000' AS DateTime), N'Ut concursionibus inter se reprehensiones non sunt', N'22688731-1c74-40c6-a32d-b1fc7826b0ad')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'af0f7112-c35c-4147-8180-b1b02cb87866', N'ca19992d-7bc5-4903-8fba-699825411b95', 3, CAST(87.40 AS Decimal(18, 2)), CAST(N'2024-12-04T20:52:34.000' AS DateTime), N'Omnia dixi hausta e fonte naturae si tota oratio n', N'd1affaf8-ae93-4465-b104-01d53600abfd')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'bf2385e5-d757-4532-a3f2-c8d15bb82ea5', N'd7461fd9-005f-47c5-aed6-98c6b03f378b', 2, CAST(116.38 AS Decimal(18, 2)), CAST(N'2024-07-09T23:39:01.000' AS DateTime), N'Sic sapientia quae ars vivendi putanda est non sat', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'c13f3200-d883-4db0-bb95-015570c879ce', N'6d17ee21-72d5-4fb5-a638-ef220307dcd9', 2, CAST(110.60 AS Decimal(18, 2)), CAST(N'2024-07-09T17:14:18.000' AS DateTime), N'Modo docui cognitionis regula et iudicio ab eadem ', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'c15c756d-4ab5-4a51-be2a-771cb9ed484c', N'def2f626-6db4-4fea-baa2-33fafd90c494', 2, CAST(95.81 AS Decimal(18, 2)), CAST(N'2024-06-19T02:42:30.000' AS DateTime), N'Corporis suscipit laboriosam nisi ut', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'c4623a1d-1edd-48af-b31d-420c2d6204a8', N'916673e7-fd52-47ed-bece-efb700890f1f', 1, CAST(78.95 AS Decimal(18, 2)), CAST(N'2024-11-02T14:01:39.000' AS DateTime), N'Homero Ennius Afranius a Menandro solet Nec vero u', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'c9c9d00d-3179-4cf5-99de-49f412c3493b', N'48eef121-050c-4362-b2b1-96a32f5fe6a9', 2, CAST(77.68 AS Decimal(18, 2)), CAST(N'2024-08-22T00:37:33.000' AS DateTime), N'Est vel summum bonorum vel ultimum vel extremum --', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'cb903db5-4abc-4f1e-be63-28942a0b60bf', N'5ea6c838-111c-484c-9b2b-bc4b5776f48f', 1, CAST(119.04 AS Decimal(18, 2)), CAST(N'2024-09-18T14:52:43.000' AS DateTime), N'Summumque malum dolorem idque instituit docere sic', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'cd0f3ec1-1c71-4e5e-b46c-f6b646bbe584', N'c4dd8020-5b57-4739-9d49-0f7172ffaf3f', 2, CAST(115.31 AS Decimal(18, 2)), CAST(N'2025-01-10T12:45:04.000' AS DateTime), N'Spe pariendarum voluptatum seiungi non potest Atqu', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'd5d6a84e-c67f-46e6-89ac-0e07504f7c08', N'418a133e-5e1f-4377-8d48-63de24b5b08e', 2, CAST(122.28 AS Decimal(18, 2)), CAST(N'2025-03-25T12:34:30.000' AS DateTime), N'Mutae etiam bestiae paene loquuntur magistra ac du', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'd7e72657-f5f8-46a4-afc2-d369a09bb80c', N'2b4fc68b-f926-4889-910b-634ad923efea', 3, CAST(87.82 AS Decimal(18, 2)), CAST(N'2024-04-27T16:34:29.000' AS DateTime), N'Esse deterritum Quae cum dixisset Explicavi inquit', N'871bbb2a-2528-4586-a1a6-e7ecd561e57e')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'daf27919-e34c-45cc-bd77-3201733aa2c6', N'15c1de08-94a5-482d-9db5-682a1581ed84', 1, CAST(124.13 AS Decimal(18, 2)), CAST(N'2024-07-11T13:05:13.000' AS DateTime), N'Quam ob rem tandem inquit non satisfacit Te enim i', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'dc1bb493-0915-458c-90d9-ecff268fdda3', N'11d9d6f7-35d3-4ba3-bcca-a6b1e8f68519', 3, CAST(106.92 AS Decimal(18, 2)), CAST(N'2024-11-05T16:47:24.000' AS DateTime), N'Quam interrogare aut interrogari Ut placet inquam ', N'11113f52-2f36-4336-ab6e-c4104e169f74')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'dd3d47a9-307b-47d3-b3df-dfd5b10a2935', N'85202b58-ec17-4407-ae0b-fab4ae861dac', 2, CAST(112.49 AS Decimal(18, 2)), CAST(N'2024-11-29T17:48:29.000' AS DateTime), N'Vivere Huic certae stabilique', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'df4db5e5-0987-48df-b954-6ba77c7bdf7e', N'07a36a4b-7943-4634-b17a-7c7eb4407cd3', 1, CAST(79.10 AS Decimal(18, 2)), CAST(N'2024-08-11T19:46:41.000' AS DateTime), N'Quae dicat ille bene noris Nisi mihi Phaedrum inqu', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'dfdb6f48-5540-4835-8596-c6f67f168628', N'9cd97ecb-58c9-4610-b4b1-d9f72bcae7f7', 1, CAST(88.26 AS Decimal(18, 2)), CAST(N'2024-07-06T00:24:11.000' AS DateTime), N'Pro suis suscipit ut non modo fautrices fidelissim', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'e12db48f-44aa-4560-a297-e9149f868616', N'c044b4de-6caf-4d33-91d3-50c621e194b0', 3, CAST(96.51 AS Decimal(18, 2)), CAST(N'2024-09-03T20:50:20.000' AS DateTime), N'Praeclaram beate vivendi et apertam et simplicem e', N'4cc784c2-f1f8-4964-b968-0c7488738bd7')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'e94ec941-e240-4fa9-8a6f-a1360c17669a', N'5b98a4b0-ee51-4b17-9584-d5ae35ce9e6b', 1, CAST(102.25 AS Decimal(18, 2)), CAST(N'2025-01-26T16:45:37.000' AS DateTime), N'Ulla pars vacuitate doloris sine iucundo motu volu', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'ECE3DD5A-61D7-4C20-9754-1343AF06C208', N'07a36a4b-7943-4634-b17a-7c7eb4407cd3', 3, CAST(100.00 AS Decimal(18, 2)), CAST(N'2025-05-05T21:16:20.800' AS DateTime), N'Transfer ke teman', N'72923966-A27D-4221-B929-B2B1CD7AA139')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'ed1ffc6b-26b2-47a3-8fbc-f51ff7c37459', N'a6d46634-1645-4107-8594-983d4a4c90ce', 1, CAST(98.37 AS Decimal(18, 2)), CAST(N'2025-03-07T12:53:57.000' AS DateTime), N'Molestiae gaudemus omne autem id quo gaudemus volu', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'eefcf327-64d3-4df3-a0da-cbb3f90e0948', N'2229fe26-cc7f-4a58-9caf-d79a7f45b93e', 2, CAST(75.13 AS Decimal(18, 2)), CAST(N'2025-03-08T22:17:42.000' AS DateTime), N'Bonas verbis electis graviter ornateque dictas qui', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'f0de775e-d24a-4ede-b55f-4c1e2ca9783c', N'8a54f7b6-3ac0-4aee-88c4-ff386444e673', 1, CAST(106.17 AS Decimal(18, 2)), CAST(N'2024-10-24T14:41:22.000' AS DateTime), N'Desiderat'' -- Nihil sane -- ''At si voluptas esset ', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'f27b482c-cc6c-4e97-a535-297a76cbb76b', N'72acc609-0cc6-4fcd-bad7-5d7e6c58ae3d', 2, CAST(103.42 AS Decimal(18, 2)), CAST(N'2024-07-13T03:41:49.000' AS DateTime), N'Liberatione et vacuitate omnis molestiae gaudemus ', NULL)
GO
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'f49e2d66-5fcc-45fb-ac4c-6c51b826f78d', N'905660c8-d6a7-40e9-9be3-e6711d22efb6', 3, CAST(118.44 AS Decimal(18, 2)), CAST(N'2025-03-21T05:47:34.000' AS DateTime), N'Affectus et firmitatem animi nec mortem nec dolore', N'cbbddf5e-529c-4f85-a28f-240f2538e4ab')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'f60e2ff4-d09d-4749-adbf-d2825617050e', N'8d8d1450-995a-4db8-84d1-47779bd7d233', 1, CAST(109.79 AS Decimal(18, 2)), CAST(N'2024-07-26T01:53:46.000' AS DateTime), N'Videntur leviora veniamus Quid tibi Torquate quid ', NULL)
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'f8bbc3ae-793a-4592-949c-20934594b7e1', N'a2ab1bd6-0020-4555-ba43-5c1f69332851', 3, CAST(92.48 AS Decimal(18, 2)), CAST(N'2024-09-03T03:03:12.000' AS DateTime), N'Est non expeteretur si nihil tale metuamus Iam ill', N'4bf5e5e2-cd9d-4927-9b82-473bba7e1191')
INSERT [dbo].[transactions] ([transaction_id], [account_id], [transaction_type_id], [amount], [transaction_date], [description], [reference_account]) VALUES (N'fb75bb86-0809-475d-831c-d565d459156f', N'80d384e7-9b48-4806-9897-32969e337683', 1, CAST(94.92 AS Decimal(18, 2)), CAST(N'2024-12-30T19:52:31.000' AS DateTime), N'Nam si ea sola voluptas esset quae quasi delapsa d', NULL)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [In_acc_type_balance]    Script Date: 01/06/2025 14:56:18 ******/
CREATE NONCLUSTERED INDEX [In_acc_type_balance] ON [dbo].[accounts]
(
	[account_type] ASC,
	[balance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [InAccount_Id]    Script Date: 01/06/2025 14:56:18 ******/
CREATE NONCLUSTERED INDEX [InAccount_Id] ON [dbo].[accounts]
(
	[account_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [InTrans]    Script Date: 01/06/2025 14:56:18 ******/
CREATE NONCLUSTERED INDEX [InTrans] ON [dbo].[transactions]
(
	[transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[accounts] ADD  DEFAULT (newid()) FOR [account_id]
GO
ALTER TABLE [dbo].[accounts] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[cards] ADD  DEFAULT (newid()) FOR [card_id]
GO
ALTER TABLE [dbo].[customers] ADD  CONSTRAINT [DF_customers_customer_id]  DEFAULT (newid()) FOR [customer_id]
GO
ALTER TABLE [dbo].[customers] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[loans] ADD  DEFAULT (newid()) FOR [loan_id]
GO
ALTER TABLE [dbo].[transactions] ADD  DEFAULT (newid()) FOR [transaction_id]
GO
ALTER TABLE [dbo].[transactions] ADD  DEFAULT (getdate()) FOR [transaction_date]
GO
ALTER TABLE [dbo].[accounts]  WITH CHECK ADD  CONSTRAINT [FK_accounts_customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[customers] ([customer_id])
GO
ALTER TABLE [dbo].[accounts] CHECK CONSTRAINT [FK_accounts_customers]
GO
ALTER TABLE [dbo].[cards]  WITH CHECK ADD  CONSTRAINT [FK_cards_accounts] FOREIGN KEY([account_id])
REFERENCES [dbo].[accounts] ([account_id])
GO
ALTER TABLE [dbo].[cards] CHECK CONSTRAINT [FK_cards_accounts]
GO
ALTER TABLE [dbo].[loans]  WITH CHECK ADD  CONSTRAINT [FK_loans_customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[customers] ([customer_id])
GO
ALTER TABLE [dbo].[loans] CHECK CONSTRAINT [FK_loans_customers]
GO
ALTER TABLE [dbo].[transactions]  WITH CHECK ADD  CONSTRAINT [FK_transactions_accounts] FOREIGN KEY([account_id])
REFERENCES [dbo].[accounts] ([account_id])
GO
ALTER TABLE [dbo].[transactions] CHECK CONSTRAINT [FK_transactions_accounts]
GO
ALTER TABLE [dbo].[transactions]  WITH CHECK ADD  CONSTRAINT [FK_transactions_transaction_types] FOREIGN KEY([transaction_type_id])
REFERENCES [dbo].[transaction_types] ([transaction_type_id])
GO
ALTER TABLE [dbo].[transactions] CHECK CONSTRAINT [FK_transactions_transaction_types]
GO
ALTER TABLE [dbo].[accounts]  WITH CHECK ADD  CONSTRAINT [CK_accounts_account_type] CHECK  (([account_type]='credit' OR [account_type]='current' OR [account_type]='savings'))
GO
ALTER TABLE [dbo].[accounts] CHECK CONSTRAINT [CK_accounts_account_type]
GO
ALTER TABLE [dbo].[cards]  WITH CHECK ADD  CONSTRAINT [CK_cards_card_type] CHECK  (([card_type]='credit' OR [card_type]='debit'))
GO
ALTER TABLE [dbo].[cards] CHECK CONSTRAINT [CK_cards_card_type]
GO
ALTER TABLE [dbo].[loans]  WITH CHECK ADD  CONSTRAINT [CK_loans_status] CHECK  (([status]='defaulted' OR [status]='closed' OR [status]='active'))
GO
ALTER TABLE [dbo].[loans] CHECK CONSTRAINT [CK_loans_status]
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateAccount]    Script Date: 01/06/2025 14:56:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CreateAccount]
    @customer_id CHAR(36),
    @account_number VARCHAR(20),
    @account_type VARCHAR(20),
    @balance DECIMAL(18, 2)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM customers WHERE customer_id = @customer_id)
    BEGIN
        INSERT INTO accounts (account_id, customer_id, account_number, account_type, balance, created_at)
        VALUES (NEWID(), @customer_id, @account_number, @account_type, @balance, GETDATE());
    END
    ELSE
    BEGIN
        PRINT 'Customer ID tidak ditemukan';
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateCustomer]    Script Date: 01/06/2025 14:56:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CreateCustomer]
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @email VARCHAR(50),
    @phone_number VARCHAR(20),
    @address VARCHAR(255)
AS
BEGIN
    INSERT INTO customers (customer_id, first_name, last_name, email, phone_number, address, created_at)
    VALUES (NEWID(), @first_name, @last_name, @email, @phone_number, @address, GETDATE());
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCustomerSummary]    Script Date: 01/06/2025 14:56:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetCustomerSummary]
    @customer_id CHAR(36)
AS
BEGIN
    SELECT 
        CONCAT(first_name, ' ', last_name) AS full_name,
        (SELECT COUNT(*) FROM accounts WHERE customer_id = @customer_id) AS total_accounts,
        (SELECT SUM(balance) FROM accounts WHERE customer_id = @customer_id) AS total_balance,
        (SELECT COUNT(*) FROM loans WHERE customer_id = @customer_id AND status = 'Active') AS active_loans,
        (SELECT SUM(loan_amount) FROM loans WHERE customer_id = @customer_id AND status = 'Active') AS total_loan_amount
    FROM customers
    WHERE customer_id = @customer_id;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_MakeTransaction]    Script Date: 01/06/2025 14:56:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_MakeTransaction]
    @account_id CHAR(36),
    @transaction_type_id INT,
    @amount DECIMAL(18,2),
    @description VARCHAR(255),
    @reference_account CHAR(36) = NULL
AS
BEGIN
    DECLARE @current_balance DECIMAL(18,2);
    SELECT @current_balance = balance FROM accounts WHERE account_id = @account_id;

    IF @transaction_type_id = 2 AND @amount > @current_balance 
        RETURN;

    INSERT INTO transactions (transaction_id, account_id, transaction_type_id, amount, description, reference_account)
    VALUES (NEWID(), @account_id, @transaction_type_id, @amount, @description, @reference_account);

    IF @transaction_type_id != 1 
        UPDATE accounts SET balance = balance - @amount WHERE account_id = @account_id;
END;
GO
USE [master]
GO
ALTER DATABASE [bank] SET  READ_WRITE 
GO
