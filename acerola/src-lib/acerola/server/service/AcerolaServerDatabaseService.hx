package acerola.server.service;

import acerola.server.error.AcerolaServerError;
import acerola.server.service.behavior.AcerolaServiceBehaviorDatabase;
import database.DatabaseSuccess;
import database.DatabaseError;
import database.DatabaseRequest;

/**
    Classe de serviço especializada em interações com banco de dados que fornece funcionalidades para executar consultas SQL e processar seus resultados.
    
    #### Responsabilidades:
    - **Gerenciamento de consultas**: Fornece métodos para executar diferentes tipos de consultas SQL e tratar seus resultados.
    - **Tratamento de erros**: Lida com erros de banco de dados e os converte em respostas de erro apropriadas.
    - **Gerenciamento de tickets**: Administra os tickets de conexão do banco de dados através do comportamento `AcerolaServiceBehaviorDatabase`.
    - **Abstração de consulta**: Oferece uma interface simplificada para operações comuns de banco de dados como selecionar, executar e processar dados.
**/
class AcerolaServerDatabaseService<S> extends AcerolaServerServiceRest<S> {

    override function setupBehavior() {
        super.setupBehavior();
        this.behavior.addBehavior(AcerolaServiceBehaviorDatabase);
    }

    /**
        Executa uma consulta genérica no banco de dados.
        
        Este método delega a execução da consulta para o comportamento de banco de dados e fornece 
        tratamento de erro padrão quando nenhum manipulador de erro personalizado é fornecido.

        @param query:DatabaseRequest<Q> a consulta a ser executada no banco de dados
        @param onComplete:(success:DatabaseSuccess<Q>)->Void função callback chamada quando a consulta for concluída com sucesso
        @param onError:(error:DatabaseError)->Void função callback opcional para tratamento personalizado de erros
    **/
    public function query<Q>(query:DatabaseRequest<Q>, onComplete:(success:DatabaseSuccess<Q>)->Void, ?onError:(error:DatabaseError)->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).query(
            query,
            onComplete,
            (err:DatabaseError) -> {
                if (onError == null) this.resultError(AcerolaServerError.SERVER_ERROR(err.message));
                else onError(err);
            }
        );
    }

    /**
        Executa uma consulta que não retorna dados (como INSERT, UPDATE, DELETE).
        
        Este método é útil para operações que modificam dados mas não necessitam de valores retornados.

        @param query:DatabaseRequest<Q> a consulta a ser executada no banco de dados
        @param onComplete:()->Void função callback chamada quando a consulta for concluída com sucesso
    **/
    public function queryRun<Q>(query:DatabaseRequest<Q>, onComplete:()->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).queryRun(
            query,
            onComplete,
            this.resultError
        );
        
    }

    /**
        Executa uma consulta que retorna um único registro.
        
        Esta é uma função de conveniência para consultas que devem retornar apenas um resultado.
        Quando nenhum registro é encontrado, um erro 404 (Not Found) será gerado através do
        manipulador de erro padrão `resultError` do serviço, indicando que o recurso solicitado
        não foi encontrado na base de dados.

        @param query:DatabaseRequest<Q> a consulta para selecionar um único registro
        @param onRead:(data:Q)->Void função callback para processar o registro retornado
    **/
    public function querySelectOne<Q>(query:DatabaseRequest<Q>, onRead:(data:Q)->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).querySelectOne(
            query,
            onRead,
            this.resultError
        );
    }

    /**
        Executa uma consulta que retorna múltiplos registros.
        
        Este método permite configurar se a ausência de resultados deve gerar um erro 404.

        @param query:DatabaseRequest<Q> a consulta para selecionar registros
        @param protectFrom404:Bool se verdadeiro, retorna um erro 404 quando nenhum registro é encontrado
        @param onRead:(data:Array<Q>)->Void função callback para processar os registros retornados
    **/
    public function querySelect<Q>(query:DatabaseRequest<Q>, protectFrom404:Bool, onRead:(data:Array<Q>)->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).querySelect(
            query,
            protectFrom404,
            onRead,
            this.resultError
        );
    }

    override function runBeforeResult(isSuccess:Bool, callback:() -> Void) {
        super.runBeforeResult(isSuccess, () -> {
            this.behavior.get(AcerolaServiceBehaviorDatabase).closeDatabaseTicket(callback, isSuccess);
        });
    }

    override function runAfterResult(isSuccess:Bool):Void {
        super.runAfterResult(isSuccess);
    }

}