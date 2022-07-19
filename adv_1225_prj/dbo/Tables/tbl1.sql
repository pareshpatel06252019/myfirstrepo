CREATE TABLE [dbo].[tbl1] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [code]        VARCHAR (10)  NULL,
    [description] VARCHAR (255) NULL,
    [TRANDATE]    DATETIME      DEFAULT (getdate()) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_code]
    ON [dbo].[tbl1]([code] ASC);

