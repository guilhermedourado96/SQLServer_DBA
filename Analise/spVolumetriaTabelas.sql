/************************************************************************************************************************
• Autor............:	Guilherme Dourado
• Contatos.........:	https://www.linkedin.com/in/analistaguilhermedourado / guilhermedourado96@gmail.com
• Script...........:	spVolumetriaTabelas
• Data criacao.....:	16/12/2025	
• Ultima alteração.:	--/--/----
• Desrição script..:	Este script retorna a volumetria e espaço alocado por cada tabela do nome do banco de dados 
						repassado como parâmetro ou do banco de dados da sessão atual(caso o banco não seja informado)
						em formato tabular.

*************************************************************************************************************************/
CREATE PROC spVolumetriaTabelas @NOME_BANCO VARCHAR(128) = NULL AS
BEGIN 
	BEGIN TRY
		DECLARE @NOME_TABELA	NVARCHAR(100), 
				@ERRO			VARCHAR(MAX),
				@ID_BD				INT

		IF @NOME_BANCO IS NOT NULL
			SELECT @ID_BD = DATABASE_ID FROM SYS.DATABASES (NOLOCK) WHERE NAME = @NOME_BANCO
		ELSE
			SELECT @ID_BD = DB_ID();

		IF (@NOME_BANCO IS NOT NULL AND @ID_BD IS NULL)
			RAISERROR('Banco "%s" não localizado',16,1,@NOME_BANCO)
		
		IF OBJECT_ID('##TEMPDB..#TABELAS','U') IS NOT NULL DROP TABLE #TABELAS
		CREATE TABLE #TABELAS (	TABELA			VARCHAR(128), 
								QTDE_REGI		INT,
								RESERVADO		VARCHAR(30), 
								DADOS			VARCHAR(30), 
								INDICE			VARCHAR(30), 
								NAO_USADO		VARCHAR(30))
		
		DECLARE CRCURSOR CURSOR FOR
			SELECT	OBJ.NAME AS TABELA
			FROM SYS.SYSOBJECTS AS OBJ (NOLOCK)
			INNER JOIN SYS.SYSINDEXES AS IDX (NOLOCK)
				ON OBJ.ID = IDX.ID
			INNER JOIN SYS.TABLES T (NOLOCK)
				ON OBJ.ID = T.OBJECT_ID
			WHERE  OBJ.TYPE = 'U'
			AND IDX.INDID < 2
		OPEN CRCURSOR;
		FETCH CRCURSOR INTO @NOME_TABELA
		WHILE(@@FETCH_STATUS <> -1)
		BEGIN
			IF(@@FETCH_STATUS <> -2)
			BEGIN
				BEGIN TRY
					INSERT INTO #TABELAS
					EXEC SP_SPACEUSED @NOME_TABELA
				END TRY
				BEGIN CATCH
					SET @ERRO = CONCAT('Erro na inserção das infos da tabela ', @nome_tabela, ' - Erro: ',ERROR_MESSAGE())
					PRINT @ERRO;;
				END CATCH
			END
			FETCH NEXT FROM CRCURSOR INTO @NOME_TABELA
		END
		CLOSE CRCURSOR;
		DEALLOCATE CRCURSOR;
		
		SELECT 
		TABELA, 
		QTDE_REGI, 
		CONCAT(CAST((CAST(DBO.FNSOMENTENUMEROS(RESERVADO)	AS NUMERIC(18,2)) /1024)AS NUMERIC(18,2)) ,' MB (',RESERVADO,')')	AS ESPACO_RESERVADO,
		CONCAT(CAST((CAST(DBO.FNSOMENTENUMEROS(DADOS)		AS NUMERIC(18,2)) /1024)AS NUMERIC(18,2)) ,' MB (',DADOS,	')')	AS ESPACO_USADO,
		CONCAT(CAST((CAST(DBO.FNSOMENTENUMEROS(INDICE)		AS NUMERIC(18,2)) /1024)AS NUMERIC(18,2)) ,' MB (',INDICE,	')')	AS ESPACO_INDICE,
		CONCAT(CAST((CAST(DBO.FNSOMENTENUMEROS(NAO_USADO)	AS NUMERIC(18,2)) /1024)AS NUMERIC(18,2)) ,' MB (',NAO_USADO,')')	AS NAO_USADO
		FROM #TABELAS 
		ORDER BY 2 DESC,4 DESC
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END