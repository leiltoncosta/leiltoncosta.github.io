# Controle de Distratos

Controle de prazos extrajudiciais dos loteamentos. A equipe lança o distrato e anexa a
minuta, o Dr. Leilton corrige e anexa a versão corrigida, e o painel mostra a qualquer
momento o que está **para corrigir** e o que já foi **corrigido**.

**Endereço do sistema:** https://regodiasdaniel.github.io/controle-distratos/

Funciona no computador e no celular. Não precisa instalar nada — é só abrir o link e fazer
login. O mesmo arquivo também roda offline com duplo clique em `index.html`, mas aí os
dados continuam vindo da nuvem, então precisa de internet de qualquer forma.

---

## Como se usa no dia a dia

### Equipe

1. **+ Novo distrato** → escolhe o loteamento e preenche adquirente, quadra/lote,
   contrato e o **prazo** para correção. Já dá para anexar a minuta na mesma tela.
2. O distrato nasce na coluna **A corrigir** do painel.
3. Marcar como **Urgente** joga o item para o topo da fila.

### Dr. Leilton

1. Abre o sistema e vê na coluna **A corrigir** tudo que está esperando por ele,
   ordenado por prazo — urgente primeiro, depois atrasado, depois o que vence hoje.
2. Clica no distrato, **Baixar** a minuta, corrige no Word.
3. Em *Versão corrigida pelo Dr. Leilton*, clica em **+ Anexar** e sobe o arquivo.
   O cartão muda sozinho para a coluna **Corrigido**.
4. Se precisar, escreve em *Apontamentos da correção* o que a equipe deve observar.

### Depois

- A equipe baixa a versão corrigida pelo botão **Baixar**, direto no painel, e ao devolver
  ao loteamento clica em **Finalizar**.
- Todo movimento — anexos, mudança de status, apontamentos — fica registrado no
  **Histórico** de cada distrato, com data, hora e quem fez.

### Extrajudiciais

A aba **Extrajudiciais** controla as diligências: ir ao cartório, protocolar na prefeitura,
retirar certidão, reconhecer firma. Cada registro guarda onde ir, qual órgão, endereço,
data e horário, responsável e prioridade.

1. **+ Nova extrajudicial** → descreva o que precisa ser feito e marque a data.
2. A lista se organiza sozinha em **Atrasadas**, **Hoje**, **Amanhã**, **Próximos 7 dias**,
   **Mais adiante**, **Sem data marcada** e, no fim, as **Concluídas**.
3. Clique no **círculo** à esquerda para dar como feita — e de novo para reabrir.
4. Abrindo o registro, dá para anexar o **protocolo ou comprovante** e escrever o
   **resultado da diligência**: número de protocolo, certidão obtida, o que ficou pendente.

Cada extrajudicial pode ser ligada a um loteamento e a um distrato específico — útil para registrar
"levar o distrato DST-0003 ao cartório". O que estiver atrasado ou vencendo hoje também
aparece no Painel, logo abaixo do quadro de colunas.

## Detalhes úteis

- **Várias versões do mesmo arquivo**: pode anexar quantas quiser. A mais recente fica
  marcada como *atual*; as anteriores continuam disponíveis para consulta.
- **Busca** (topo): procura por adquirente, lote, contrato, empreendimento ou código.
- **Painel**: é um relatório. Mostra dois gráficos de rosca lado a lado — um de distratos,
  outro de extrajudiciais — com a divisão por situação, quantidade e percentual de cada
  fatia. Em cima, quatro números: pendentes de cada lado, atrasados e vencendo hoje.
  Clicar em qualquer número, fatia da legenda ou botão *Abrir* leva à lista já filtrada.
- **Quadro de colunas**: fica na aba **Distratos**, no botão *Quadro* ao lado dos filtros.
  O distrato caminha de *A corrigir* até *Finalizado*, e dá para **arrastar o cartão** de
  uma coluna para outra para mudar a situação. O botão *Lista* volta à tabela.
- **Exportar CSV**: na tela de Distratos, gera uma planilha do que estiver filtrado.
- **Tipos de documento**: além de Distrato, dá para lançar Notificação extrajudicial,
  Rescisão, Aditivo ou Outro — é o mesmo controle de prazo.
- **Tema claro/escuro**: botão da lua, no topo.
- **Limite de 25 MB** por arquivo anexado.

---

## Quem tem acesso

Só quem tem usuário criado no Supabase. Hoje são três:

- `juridico@leiltoncosta.adv.br`
- `leiltoncosta.adv@gmail.com`
- `dias.danielrego@gmail.com`

Para **adicionar ou remover** alguém: painel do Supabase → **Authentication → Users**.
Ao criar um usuário novo, marque **"Auto Confirm User"**, senão o login não entra.

> O repositório é público e a chave `sb_publishable_` aparece no código — isso é esperado,
> essa chave é feita para ficar no navegador. Quem protege os dados é o login e as regras
> de acesso do banco: sem estar logado, o Postgres recusa qualquer leitura ou gravação, e
> o storage recusa qualquer upload. Isso foi testado.

## Infraestrutura (para referência)

| Item | Onde |
|---|---|
| Banco e arquivos | Supabase, projeto `distratos` (ref `ybohudryuadtcifpuwsj`), região São Paulo |
| Código | github.com/regodiasdaniel/controle-distratos |
| Site | GitHub Pages, branch `main`, pasta raiz |
| Tabelas | `clientes`, `distratos`, `tarefas` |
| Arquivos | bucket privado `distratos`, 25 MB por arquivo |

A senha do banco Postgres **não é usada pelo sistema**. Se precisar dela algum dia e não
tiver guardado, dá para redefinir em *Settings → Database → Reset database password*.

## Se algum dia precisar recriar o banco do zero

O arquivo `schema_supabase.sql` recria tudo: tabelas, regras de acesso, bucket e gatilho.
Rode-o inteiro em **SQL Editor → New query → Run**. Ele é seguro de rodar de novo num banco
já existente — não apaga dados. Depois, recrie os usuários em *Authentication → Users* e,
se o projeto for outro, atualize `SUPABASE_URL` e `SUPABASE_ANON_KEY` no início do
`<script>` do `index.html`.
