# Fluxo de Desenvolvimento

Este repositório segue o fluxo de desenvolvimento Git com base no modelo de **Git Flow**.

## Estrutura de Branches

- **`main`**: Contém o código de produção estável.
- **`develop`**: Contém o código em desenvolvimento, pronto para novas funcionalidades.

## Criando uma Nova Funcionalidade

1. Crie uma branch a partir de `develop` com o nome `feature/nome-da-funcionalidade`.
2. Realize as modificações necessárias e faça commits organizados. Exemplo de mensagem de commit:
   - `feat: adiciona a funcionalidade de login`
3. Quando terminar a funcionalidade, crie um Pull Request (PR) da branch `feature/nome-da-funcionalidade` para `develop`.

## Integração com `main`

Quando todas as funcionalidades da `develop` estiverem testadas e prontas, crie um PR de `develop` para `main` e faça o merge.

## GitHub Actions

O repositório está configurado para rodar ações do GitHub, incluindo testes automáticos e verificação de qualidade do código. Verifique a seção de ações para mais detalhes.
