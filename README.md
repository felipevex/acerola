Coletando informações do workspace# Acerola

# ACEROLA

Acerola é um framework Haxe para desenvolvimento de serviços web RESTful moderno, flexível e de alta performance. Projetado para facilitar a criação de APIs estruturadas com validação robusta, o Acerola permite que você construa serviços web altamente testáveis e escaláveis.

## 📋 Sumário

- Visão Geral
- Recursos
- Vantagens e Limitações
- Começando
- Exemplos
- Documentação
- Desenvolvimento e Testes
- Licença

## 🚀 Visão Geral

Acerola é uma biblioteca Haxe que facilita a criação de servidores web e APIs RESTful com foco em estrutura clara, validação de dados, e fluxo de trabalho organizado. Com suporte integrado para manipulação de banco de dados, rotas parametrizadas e comportamentos reutilizáveis, o Acerola permite construir aplicações web escaláveis em múltiplas plataformas através do poder do Haxe.

## ✨ Recursos

- **Roteamento Poderoso**: Suporte para rotas parametrizadas com validação de tipos (`/v1/test-get/[id:Int]/[hello:String]`)
- **Validação de Dados**: Integração com `AnonStruct` para validação robusta de dados de entrada
- **Arquitetura Orientada a Serviços**: Estrutura clara para implementação de endpoints através de classes de serviço
- **Integração com Banco de Dados**: Suporte nativo para MySQL
- **Testes Automatizados**: Framework de testes integrado tanto para testes unitários quanto de API
- **Comportamentos Reutilizáveis**: Sistema de comportamentos para compartilhar funcionalidades entre serviços
- **Gestão de Requisições**: Classes para manipulação fácil de requisições HTTP

## 🔍 Vantagens e Limitações

### Vantagens

- **Tipagem Forte**: Segurança de tipos e validação robusta para APIs mais confiáveis
- **Estrutura Organizada**: Arquitetura clara para separação de responsabilidades
- **Testes Abrangentes**: Ferramentas para testes unitários e de API
- **Dev Container Pronto**: Ambiente de desenvolvimento consistente com Docker

### Limitações

- **Curva de Aprendizado**: Requer conhecimento básico de Haxe
- **Projeto em Desenvolvimento**: Algumas APIs podem mudar conforme o framework evolui
- **Ecossistema**: Menor ecossistema quando comparado a frameworks mais estabelecidos

## 🏁 Começando

### Usando Dev Container (Recomendado)

A maneira mais fácil de começar com Acerola é usando o Dev Container incluído, que configurará todo o ambiente necessário para você:

1. Certifique-se de ter o Docker e VS Code com a extensão Remote Development instalados
2. Clone o repositório: `git clone https://github.com/felipevex/acerola.git`
3. Abra o projeto no VS Code
4. Quando solicitado, clique em "Reopen in Container" ou execute o comando "Remote-Containers: Open Folder in Container" 
5. Aguarde enquanto o container é construído e configurado

O Dev Container já inclui:
- Haxe 4.3.3
- Todas as dependências necessárias
- Ambiente Node.js para compilação e execução
- Bancos de dados MySQL configurados

## 📝 Exemplos

### Criando um Serviço REST Simples

```haxe
class HelloWorldJsonService extends AcerolaServerServiceRest<{hello:String}> {
    override function run() {
        this.resultSuccess({hello: "world"});
    }
}

// No arquivo de configuração do servidor
server.route.register(GetHelloWorldJson, HelloWorldJsonService);
```

### Validando Parâmetros da Requisição

```haxe
// Definição de rota com parâmetros tipados
class GetTestGet extends AcerolaRequest<TestGetServiceData, TestGetServiceData, Nothing> {
    public function new() {
        super(AcerolaServerVerbsType.GET, '/v1/test-get/[id:Int]/[hello:String]');
    }
}

// Serviço que usa validação de parâmetros
class TestGetService extends AcerolaServerServiceRest<TestGetServiceData> {
    override function setup() {
        this.paramsValidator = TestGetServiceDataValidator;
    }

    override function run() {
        var params:TestGetServiceData = this.req.params;        
        this.resultSuccess(params);
    }
}
```

## 📚 Desenvolvimento e Testes

### Executando Testes

Com os containers ativos, você pode facilmente executar todos os testes automáticos da biblioteca usando:

```bash
cd /acerola
bash run.sh
```

Este script:
1. Compila o exemplo
2. Compila os testes unitários
3. Compila os testes de API
4. Inicia o servidor
5. Executa os testes unitários
6. Executa os testes de API
7. Encerra o servidor

### Estrutura dos Testes

- `src-test/acerola/test/unit/`: Testes unitários
- `src-test/acerola/test/api/`: Testes de integração da API

## 📖 Documentação

A documentação completa do código está disponível em: [http://felipevex.github.io/acerola](http://felipevex.github.io/acerola)

Para gerar a documentação localmente:

```bash
cd /acerola
bash create-dox.sh
```

## 🧰 Estrutura do Projeto

```
acerola/
  ├── build/            # Saída da compilação
  ├── src-example/      # Exemplos de uso
  ├── src-lib/          # Código fonte da biblioteca
  ├── src-test/         # Testes unitários e de API
  ├── run.sh            # Script para executar testes
  ├── create-dox.sh     # Script para gerar documentação
  └── haxe-dox.hxml     # Configuração de compilação para documentação
```

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo LICENSE para mais detalhes.

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

---

Desenvolvido com ❤️ por [felipevex](https://github.com/felipevex)