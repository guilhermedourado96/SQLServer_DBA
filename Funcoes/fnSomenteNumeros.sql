/************************************************************************************************************************
• Autor............:	Guilherme Dourado
• Contatos.........:	https://www.linkedin.com/in/analistaguilhermedourado / guilhermedourado96@gmail.com
• Script...........:	spVolumetriaTabelas
• Data criacao.....:	16/12/2025	
• Ultima alteração.:	--/--/----
• Desrição script..:	Recebe uma string de 100 caracteres, deleta quaisquer caracteres diferentes de numeros e retorna
                        o resultado.
*************************************************************************************************************************/

CREATE FUNCTION [DBO].[fnSomenteNumeros] (@PALAVRA VARCHAR (100)) RETURNS VARCHAR (100) AS
BEGIN
DECLARE
    @RESULTADO VARCHAR (1000), 
    @LETRA VARCHAR(1),
    @QTD_PALAVRA INTEGER,
    @CONT INTEGER

SET @CONT = 0
SET @QTD_PALAVRA = LEN(@PALAVRA)
SET @RESULTADO = ''
WHILE @CONT < @QTD_PALAVRA
BEGIN 
    SET @CONT = @CONT + 1
    SET @LETRA = SUBSTRING(@PALAVRA,@CONT,1)
    IF @LETRA  IN ('0','1','2','3','4','5','6','7','8','9' )
    BEGIN
       SET @RESULTADO =  @RESULTADO + @LETRA
    END
END
RETURN @RESULTADO 
END
