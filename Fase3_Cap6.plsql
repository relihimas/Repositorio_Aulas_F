--Atividade_cap6_fase3_RM86546

--1.	Automação de aviso para estoque em “quantidade crítica”:
--a.	Montar uma procedure, com uma função interna que calcula o giro de estoque de cada produto, caso a quantidade em estoque seja classificada pela condição interna em “quantidade crítica” deve ser mostrada quando a procedure for retornada pelo usuário no front ou envio para e-mail pelo ERP.

--2.	Automação de aviso de novo pedido de compra ao Almoxarifado:  
--a.	Após um novo pedido de compra ser feito pelo setor de Suprimentos, o ERP ativa uma procedure que retorna todos os pedidos de compra que foram realizados e que ainda não foram recebidos para monitoramento de Suprimentos e verificação de recebimento pelo Almoxarifado. Podemos acrescentar um para aviso de pedido de compra recebido. 

--Realizei as seguintes alterações para melhor ajuste do que eu queria com as premissas de negócio para continuar a questão:
--1. criei uma procedure que faz o input do novo pedido
--2. criei uma trigger que abrirá uma view com todas as ordens em aberto


SET SERVEROUTPUT ON

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



AFTER INSERT 



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
