--How might you ensure against orphaned data?
DROP TABLE IF EXISTS interview.InvoiceLine;
DROP TABLE IF EXISTS interview.Invoice;
GO
CREATE TABLE interview.Invoice
	(
	InvoiceId INT IDENTITY CONSTRAINT PK_Invoice PRIMARY KEY,
	CustomerId INT,
	DueDate DATE CONSTRAINT DF_Invoice_DueDate DEFAULT DATEADD(DAY, 30, GETDATE()),
	CreatedDateTime DATETIME CONSTRAINT DF_Invoice_CreatedDateTime DEFAULT GETDATE()
	);

CREATE TABLE interview.InvoiceLine
	(
	InvoiceLineId INT IDENTITY CONSTRAINT PK_InvoiceLine PRIMARY KEY,
	InvoiceId INT CONSTRAINT FK_InvoiceLine_Invoice FOREIGN KEY REFERENCES interview.Invoice(InvoiceId) ON DELETE CASCADE,
	ProductCode VARCHAR(20),
	Price MONEY CONSTRAINT CK_MinimumPrice CHECK (Price > 10)
	);
GO
CREATE OR ALTER PROCEDURE interview.usp_CreateInvoice
	(
	@CustomerId INT,
	@ProductCode VARCHAR(20),
	@Price MONEY
	)
	AS
BEGIN;
	INSERT interview.Invoice
		(
		CustomerId
		)
		SELECT @CustomerId;

	INSERT interview.InvoiceLine
		(
		InvoiceId,
		ProductCode,
		Price
		)
		SELECT InvoiceId = SCOPE_IDENTITY(),
			@ProductCode,
			@Price;
END;
GO
EXEC interview.usp_CreateInvoice @CustomerId = 1,
	@ProductCode = 'FILING',
	@Price = 100;
EXEC interview.usp_CreateInvoice @CustomerId = 1,
	@ProductCode = 'ASSET_SEARCH',
	@Price = 1;
GO
SELECT IsOrphaned = CASE WHEN il.InvoiceId IS NULL THEN 1 ELSE 0 END,
	*
	FROM interview.Invoice AS i
		LEFT OUTER JOIN interview.InvoiceLine AS il
			ON i.InvoiceId = il.InvoiceId;