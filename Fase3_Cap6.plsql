--Atividade_cap6_fase3_RM86546

--1.	Automação de aviso para estoque em “quantidade crítica”:
--a.	Montar uma procedure, com uma função interna que calcula o giro de estoque de cada produto, caso a quantidade em estoque seja classificada pela condição interna em “quantidade crítica” deve ser mostrada quando a procedure for retornada pelo usuário no front ou envio para e-mail pelo ERP.
--Criei uma tabela para o recebimento e outra para a saídas requisitadas


CREATE TABLE t_recebimento(
    idRecebimento           INTEGER NOT NULL,
    t_produto_idproduto     INTEGER NOT NULL,
    t_idnotafiscal          INTEGER NOT NULL,   
    dtEntrada               DATE,
    qte                     FLOAT NOT NULL,
    custoUnitario           FLOAT NOT NULL,
    valorEstoque            FLOAT NOT NULL);

ALTER TABLE t_recebimento
ADD CONSTRAINT "t_recebi_pk" PRIMARY KEY (idRecebimento );

ALTER TABLE t_recebimento
ADD CONSTRAINT t_produto_fk FOREIGN KEY (t_idproduto)
REFERENCES t_produto (idproduto);

ALTER TABLE t_recebimento
ADD CONSTRAINT t_idnotafiscal_fk FOREIGN KEY (t_idnotafiscal)
REFERENCES t_nota_fiscal (idnotafiscal);

################################################################################

CREATE TABLE t_requisitado(
    idRequisicao            INTEGER NOT NULL,
    t_id_recebimento        INTEGER NOT NULL,
    t_produto_idproduto     INTEGER NOT NULL, 
    dtSaida                 DATE,
    qte                     FLOAT NOT NULL,
    custoUnitario           FLOAT NOT NULL,
    valorRequisitado        FLOAT NOT NULL);
    
ALTER TABLE t_requisitado
ADD CONSTRAINT t_requisicao PRIMARY KEY (idRequisicao);

ALTER TABLE t_requisitado
ADD CONSTRAINT t_idnf_requi_fk FOREIGN KEY (t_idnotafiscal)
REFERENCES t_nota_fiscal (idnotafiscal);

ALTER TABLE t_requisitado
ADD CONSTRAINT t_produto_fk FOREIGN KEY (t_idproduto)
REFERENCES t_produto (idproduto);

################################################################################

CREATE TABLE t_vendas(
    idVenda                 INTEGER NOT NULL,
    t_produto_idproduto     INTEGER NOT NULL,
    t_idnotafiscal          INTEGER NOT NULL,   
    t_idcliente             INTEGER NOT NULL,
    dtVenda                 DATE,
    qte                     FLOAT NOT NULL,
    valorUnitario           FLOAT NOT NULL);

ALTER TABLE t_vendas
ADD CONSTRAINT t_vendas PRIMARY KEY (idVenda);

ALTER TABLE t_vendas
ADD CONSTRAINT t_idnf_requi_fk FOREIGN KEY (t_idnotafiscal)
REFERENCES t_nota_fiscal (idnotafiscal);

ALTER TABLE t_vendas
ADD CONSTRAINT t_produto_fk FOREIGN KEY (t_idproduto)
REFERENCES t_produto (idproduto);

ALTER TABLE t_vendas
ADD CONSTRAINT t_produto_fk FOREIGN KEY (t_idcliente)
REFERENCES t_cliente (idcliente);

################################################################################

CREATE TABLE t_estoque(
        idEstoque                   INTEGER NOT NULL,
        UltimaDiaEstoque            DATE,
        t_produto_idproduto         INTEGER NOT NULL,
        qte                         FLOAT NOT NULL,
        custoUnitario               FLOAT NOT NULL);
        
ALTER TABLE t_estoque
ADD CONSTRAINT t_estoque PRIMARY KEY (idEstoque );

ALTER TABLE t_estoque
ADD CONSTRAINT t_prod_esto_fk FOREIGN KEY (t_idproduto)
REFERENCES t_produto (idproduto);

################################################################################
CREATE OR REPLACE PACKAGE giroestoque AS
    FUNCTION fc_vendaanual(p_idproduto IN t_produto.idproduto%TYPE) RETURN NUMBER;
    FUNCTION fc_estoquemedio(p_idproduto IN t_produto.idproduto%TYPE) RETURN NUMBER;
    FUNCTION fc_giroestoque(p_idproduto IN  t_produto.idproduto%TYPE);
END giroestoque;

CREATE OR REPLACE PACKAGE BODY giroestoque AS
    FUNCTION fc_vendaanual
    (   p_idproduto                  IN  t_produto.idproduto%TYPE)
    RETURN NUMBER IS
        v_vendaanual := FLOAT DEFAULT 0;
    BEGIN
        SELECT  SUM (qte * valorUnitario)
        INTO    v_vendanaual
        FROM    t_vendas
        WHERE   dtVenda BETWEEN SYSDATE AND ADD_MONTHS(TRUNC(SYSDATE), -12)
                AND t_produto_idproduto = p_idproduto;
        
        RETURN v_vendaanual
    END fc_vendaanual;

    FUNCTION fc_estoquemedio
    (   p_idproduto                  IN  t_produto.idproduto%TYPE)
    RETURN NUMBER IS
        v_estoquemedio := FLOAT DEFAULT 0;
    BEGIN
        SELECT  AVG(qte)
        INTO    v_estoquemedio
        FROM    t_estoque
        WHERE   dtVenda BETWEEN SYSDATE AND ADD_MONTHS(TRUNC(SYSDATE), -12)
                AND t_produto_idproduto = p_idproduto;
        
        RETURN v_estoquemedio
    END fc_estoquemedio;

    FUNCTION fc_giroestoque
    (p_idproduto IN  t_produto.idproduto%TYPE) IS
        giro := FLOAT DEFAULT 0; 
    BEGIN
        SELECT  p_idproduto, ( fc_vendaanual(p_idproduto) / fc_estoquemedio(p_idproduto) )
        INTO    p_idproduto, giro
        FROM    dual
        WHERE   idproduto = p_idproduto
        IF (giro > 3) THEN
            DBMS_OUTPUT.PUT_LINE('Giro ok');
        ELSE 
            DBMS_OUTPUT.PUT_LINE('Giro em estado crítico - solicite compra imediatamente!!');
        RETURN giro   
    END fc_giroestoque
    
END giroestoque;


    



--2.	Automação de aviso de novo pedido de compra ao Almoxarifado:  
--a.	Após um novo pedido de compra ser feito pelo setor de Suprimentos, o ERP ativa uma procedure que retorna todos os pedidos de compra que foram realizados e que ainda não foram recebidos para monitoramento de Suprimentos e verificação de recebimento pelo Almoxarifado. Podemos acrescentar um para aviso de pedido de compra recebido. 

--Realizei as seguintes alterações para melhor ajuste do que eu queria com as premissas de negócio para continuar a questão:
--1. criei uma procedure que faz o input do novo pedido
--2. criei uma trigger que abrirá uma view com todas as ordens em aberto

SET SERVEROUTPUT ON
CREATE VIEW vw_pedidosabertos AS 
SELECT * FROM t_pedidos_compra WHERE status = 'Aberto';


CREATE OR REPLACE PROCEDURE prcd_novopedido
(   p_idpedido                  IN  t_pedidos_compra.status%TYPE,
    p_idproduto                 IN  t_pedidos_compra.status%TYPE,
    p_idfornecedor              IN  t_pedidos_compra.status%TYPE,
    p_idfuncionario             IN  t_pedidos_compra.status%TYPE,
    p_status			        IN  t_pedidos_compra.status%TYPE)
IS
BEGIN 
    INSERT INTO t_pedidos_compra (idpedido, idproduto, idfornecedor, idfuncionario, status)
    VALUES (p_idpedido, p_idproduto, p_idfornecedor, p_idfuncionario, p_status);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
END prcd_novopedido;


SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_avisonovopedido
AFTER UPDATE ON t_pedidos_compra
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Existem novas compras a serem recebidas! Cheque o relatório!');
END trg_avisonovopedido;

SELECT * FROM vw_pedidosabertos;

--3.	Cancelamento de Pedido de Compra:
--a.	Caso o setor de Suprimentos decida cancelar algum Pedido de Compra, ativa uma trigger onde altera o status para cancelado e retira da lista de espera do Almoxarifado.

SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_cancelacompra
BEFORE UPDATE OF status ON t_pedidos_compra
REFERENCING NEW AS novo_status
            OLD AS antigo_status
FOR EACH ROW
DECLARE
    v_status    t_pedidos_compra.status%TYPE;
BEGIN
    v_status := :novo_status.status;
    DBMS_OUTPUT.PUT_LINE('Status atualizado de '|| :antigo_status.status ||' para ' || :novo_status.status);
END trg_cancelacompra;


UPDATE t_pedidos_compra
   SET status = 'Cancelado'
 WHERE idpedido = XXXX;
 
 
 ALTER TABLE t_pedidos_compra
 ADD status VARCHAR2(10) NOT NULL;

--4.	Cadastro de Cliente (Pessoa Jurídica, Pessoa Física):
--a.	Montar uma procedure que facilmente entenda os dados imputados pelo usuário para que internamente ele destrinche entre Pessoa Jurídica e Física.

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE prcd_cadastro_cliente
(       v_idcliente           IN t_cliente.idcliente%TYPE DEFAULT 1,
        v_nomecliente         IN t_cliente.nomecliente%TYPE,
        v_numcep              IN t_cliente.numcep%TYPE,
        v_endereconumero      IN t_cliente.endereconumero%TYPE,
        v_enderecocliente     IN t_cliente.enderecocliente%TYPE,
        v_telefonecliente     IN t_cliente.telefonecliente%TYPE,
        v_emailcliente        IN t_cliente.emailcliente%TYPE,
        v_rua                 IN t_cliente.rua%TYPE,
        v_complemento         IN t_cliente.complemento%TYPE,
        v_cidade              IN t_cliente.cidade%TYPE
)
IS
BEGIN
    BEGIN
        INSERT INTO t_cliente (idcliente, nomecliente, numcep, endereconumero, enderecocliente, telefonecliente, emailcliente, rua, complemento, cidade)
        VALUES (v_idcliente, v_nomecliente, v_numcep, v_endereconumero, v_enderecocliente, v_telefonecliente, v_emailcliente, v_rua, v_complemento, v_cidade);
    	COMMIT;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
    END;
    IF v_idcliente = 1 THEN
        DECLARE 
            v_idcliente_fisico              t_cliente_pfisica.idcliente%TYPE;
            v_numrg                         t_cliente_pfisica.numrg%TYPE;
            v_numcpf                        t_cliente_pfisica.numcpf%TYPE;
            v_dtnascimento                  t_cliente_pfisica.dtnascimento%TYPE;
            v_idsexo                        t_cliente_pfisica.idsexo%TYPE;
            BEGIN
                INSERT INTO t_cliente_pfisica (idcliente, numrg, numcpf, dtnascimento, idsexo)
                VALUES (v_idcliente_fisico, v_numrg, v_numcpf, v_dtnascimento, v_idsexo);
                DBMS_OUTPUT.PUT_LINE('Cliente Pessoa Física criado com sucesso!');
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN ROLLBACK;
            END;
    ELSE
        DECLARE
            v_idcliente_juridico                t_cliente_pjuridica.idcliente%TYPE;
            v_razaosocial                       t_cliente_pjuridica.razaosocial%TYPE;
            v_numcnpj                           t_cliente_pjuridica.numcnpj%TYPE;
            v_numinscestadual                   t_cliente_pjuridica.numinscestadual%TYPE;
            v_ramoatividade                     t_cliente_pjuridica.ramoatividade%TYPE;
            BEGIN
                INSERT INTO t_cliente_pjuridica (idcliente, razaosocial, numcnpj, numinscestadual, ramoatividade)
                VALUES (v_idcliente_juridico, v_razaosocial, v_numcnpj, v_numinscestadual, v_ramoatividade);
                COMMIT;
                DBMS_OUTPUT.PUT_LINE('Cliente Pessoa Jurídica criado com sucesso!');
            EXCEPTION
                WHEN OTHERS THEN ROLLBACK;
            END;
    END IF;        
 	COMMIT;
EXCEPTION
	WHEN OTHERS THEN ROLLBACK;
END prcd_cadastro_cliente;           
