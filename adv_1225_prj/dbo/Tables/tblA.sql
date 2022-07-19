CREATE TABLE [dbo].[tblA] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [code]        VARCHAR (10)  NULL,
    [description] VARCHAR (255) NULL,
    [TRANDATE]    DATETIME      DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

