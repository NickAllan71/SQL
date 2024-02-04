--How might you de-duplicate Invoices?
--REQUIREMENT: Customer must only have one invoice per due date
DROP TABLE IF EXISTS interview.InvoiceLine;
DROP TABLE IF EXISTS interview.Invoice;
GO
CREATE TABLE interview.Invoice
	(
	InvoiceId INT IDENTITY PRIMARY KEY,
	CustomerId INT,
	DueDate DATE,
	CreatedDateTime DATETIME DEFAULT GETDATE()
	);

CREATE TABLE interview.InvoiceLine
	(
	InvoiceLineId INT IDENTITY PRIMARY KEY,
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
GO
SELECT *
	FROM interview.Invoice AS i
		LEFT OUTER JOIN interview.InvoiceLine AS il
			ON i.InvoiceId = il.InvoiceId;