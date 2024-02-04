--Well done for making it this far!
DROP TABLE IF EXISTS interview.InvoiceLine;
DROP TABLE IF EXISTS interview.Invoice;
GO
CREATE TABLE interview.Invoice
	(
	InvoiceId INT IDENTITY CONSTRAINT PK_Invoice PRIMARY KEY,
	CustomerId INT,
	DueDate DATE,
	CreatedDateTime DATETIME CONSTRAINT DF_Invoice_CreatedDateTime DEFAULT GETDATE()
	);
CREATE UNIQUE NONCLUSTERED INDEX UI_Invoice_CustomerId_DueDate
	ON interview.Invoice (
		CustomerId,
		DueDate
		);
CREATE TABLE interview.InvoiceLine
	(
	InvoiceLineId INT IDENTITY CONSTRAINT PK_InvoiceLine PRIMARY KEY,
	InvoiceId INT CONSTRAINT FK_InvoiceLine_Invoice FOREIGN KEY
		REFERENCES interview.Invoice(InvoiceId) ON DELETE CASCADE,
	ProductCode VARCHAR(20),
	Price MONEY CONSTRAINT CK_MinimumPrice CHECK (Price > 10)
	);
GO
CREATE OR ALTER PROCEDURE interview.usp_CreateInvoice
	(
	@CustomerId INT,
	@ProductCode VARCHAR(20),
	@Price MONEY,
	@DueDate DATE = NULL
	)
	AS
BEGIN;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	INSERT interview.Invoice
		(
		CustomerId,
		DueDate
		)
		SELECT @CustomerId,
			DueDate = ISNULL(@DueDate, DATEADD(DAY, 30, GETDATE()));

	INSERT interview.InvoiceLine
		(
		InvoiceId,
		ProductCode,
		Price
		)
		SELECT InvoiceId = SCOPE_IDENTITY(),
			@ProductCode,
			@Price;

	COMMIT TRANSACTION;
END;
GO
EXEC interview.usp_CreateInvoice @CustomerId = 1,
	@ProductCode = 'FILING',
	@Price = 100;
EXEC interview.usp_CreateInvoice @CustomerId = 2,
	@ProductCode = 'ASSET_SEARCH',
	@Price = 20;
EXEC interview.usp_CreateInvoice @CustomerId = 2,
	@ProductCode = 'ASSET_SEARCH',
	@Price = 20;
EXEC interview.usp_CreateInvoice @CustomerId = 3,
	@ProductCode = 'LITIGATION',
	@Price = 1500;
DECLARE @Today DATE = GETDATE();
EXEC interview.usp_CreateInvoice @CustomerId = 4,
	@ProductCode = 'FILING',
	@Price = 1500,
	@DueDate = @Today;
EXEC interview.usp_CreateInvoice @CustomerId = 4,
	@ProductCode = 'FILING',
	@Price = 1500;