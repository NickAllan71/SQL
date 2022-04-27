--How might you fix this?
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
GO
CREATE OR ALTER TRIGGER interview.tr_Invoice_SetDueDate
	ON interview.Invoice
	AFTER INSERT
	AS
BEGIN;
	CREATE TABLE #DueDate
		(
		Id INT IDENTITY(0, 1),
		InvoiceId INT,
		DueDate DATE
		);
	INSERT #DueDate
		(
		InvoiceId,
		DueDate
		)
		SELECT InvoiceId,
			DueDate = DATEADD(DAY, 30, CreatedDateTime)
			FROM inserted;

	UPDATE i
		SET DueDate = d.DueDate
		FROM interview.Invoice AS i
			INNER JOIN #DueDate AS d
				ON i.InvoiceId = d.InvoiceId;
END;
GO
CREATE TABLE interview.InvoiceLine
	(
	InvoiceLineId INT IDENTITY CONSTRAINT PK_InvoiceLine PRIMARY KEY,
	InvoiceId INT CONSTRAINT FK_InvoiceLine_Invoice FOREIGN KEY REFERENCES interview.Invoice(InvoiceId) ON DELETE CASCADE,
	ProductCode VARCHAR(20),
	Price MONEY
	);

INSERT interview.Invoice
	(
	CustomerId
	)
	SELECT CustomerId = 1;

INSERT interview.InvoiceLine
	(
	InvoiceId,
	ProductCode,
	Price
	)
	SELECT InvoiceId = @@IDENTITY,
		ProductCode = 'ASSET_SEARCH',
		Price = 1500;