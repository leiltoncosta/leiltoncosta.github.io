# Controle de Distratos — como colocar no ar

Sistema de controle de prazos extrajudiciais dos loteamentos: a equipe lança o distrato
e anexa a minuta, o Dr. Leilton corrige e anexa a versão corrigida, e o painel mostra,
a qualquer momento, o que está **para corrigir** e o que já está **corrigido**.

São só dois arquivos:

| Arquivo | Para que serve |
|---|---|
| `schema_supabase.sql` | Cria as tabelas e o local dos arquivos no banco. Roda **uma vez só**. |
| `index.html` | O sistema em si. É ele que você abre no navegador. |

---

## Passo 1 — Criar o banco (uma vez, ~5 minutos)

1. Entre em **https://supabase.com** e faça login.
2. **New project**. Dê o nome `distratos`, escolha a região **South America (São Paulo)**
   e defina uma senha para o banco (guarde, mas você não vai precisar dela no dia a dia).
3. Espere o projeto terminar de subir (uns 2 minutos).

## Passo 2 — Rodar o script do banco

1. No menu lateral do Supabase: **SQL Editor → New query**.
2. Abra o arquivo `schema_supabase.sql`, copie **tudo** e cole ali.
3. Clique em **Run**. Deve aparecer *Success*.

Isso cria as tabelas `clientes` e `distratos`, as regras de acesso e o bucket `distratos`,
onde ficam guardados os arquivos (.docx / .pdf), com limite de 25 MB por arquivo.

## Passo 3 — Criar os logins

No menu **Authentication → Users → Add user**, crie um usuário para cada pessoa:

- o seu (equipe) — ex.: `juridico@leiltoncosta.adv.br`
- o do Dr. Leilton

Em cada um, **marque a opção "Auto Confirm User"**, senão o Supabase fica esperando
confirmação por e-mail e o login não entra.

> Só quem tem usuário criado aqui enxerga os dados. Não existe cadastro aberto ao público.

## Passo 4 — Ligar o sistema ao banco

1. No Supabase, vá em **Project Settings → API** e copie:
   - **Project URL** (algo como `https://xxxxxxxx.supabase.co`)
   - a chave **anon / public**
2. Abra o `index.html` (duplo clique). Vai aparecer a tela de **Configuração inicial**.
3. Cole os dois valores e clique em **Salvar e conectar**.
4. Faça login com o usuário criado no passo 3.

Pronto — o sistema está funcionando.

---

## Para não configurar de novo em cada computador

A configuração fica salva no navegador. Se você quiser que o arquivo já venha pronto
(inclusive no computador do Dr. Leilton), abra o `index.html` num editor de texto,
procure estas duas linhas logo no começo do `<script>`:

```js
const SUPABASE_URL      = "";
const SUPABASE_ANON_KEY = "";
```

e preencha entre as aspas. Aí é só mandar o arquivo pronto para ele — basta abrir e logar.

> A chave `anon` é pública por natureza; ela sozinha não dá acesso a nada. Quem protege
> os dados é o login e as regras de acesso que o script SQL criou.

## Para acessar de qualquer lugar (opcional)

Do mesmo jeito que o Acervo Jurídico: crie um repositório no GitHub, suba o `index.html`
e ligue o **GitHub Pages**. Aí o sistema vira um endereço na internet, e o Dr. Leilton
acessa pelo celular ou por qualquer computador, sem instalar nada.

---

## Como se usa no dia a dia

**Equipe**
1. `+ Novo distrato` → escolhe o cliente (loteamento), preenche adquirente, quadra/lote,
   contrato e o **prazo** para correção. Já dá para anexar a minuta na mesma tela.
2. O distrato nasce com status **A corrigir** e aparece na *Fila de correção* do painel.
3. Marcar como **Urgente** joga o item para o topo da fila.

**Dr. Leilton**
1. Abre o sistema e vê no painel tudo que está esperando por ele, ordenado por prazo —
   atrasado primeiro, depois o que vence hoje.
2. Clica no distrato, **Baixar** a minuta, corrige no Word.
3. Em *Versão corrigida pelo Dr. Leilton*, clica em **+ Anexar** e sobe o arquivo.
   O status muda sozinho para **Corrigido** e o item passa para a coluna "Corrigidos".
4. Se precisar, escreve em *Apontamentos da correção* o que a equipe deve observar.

**Depois**
- A equipe baixa a versão corrigida pelo botão **Baixar** direto no painel e,
  ao devolver ao cliente, clica em **Finalizar**.
- Todo movimento (anexos, mudança de status, apontamentos) fica registrado no
  **Histórico** de cada distrato, com data, hora e quem fez.

## Detalhes úteis

- **Várias versões do mesmo arquivo**: pode anexar quantas quiser. A mais recente fica
  marcada como *atual*; as anteriores continuam disponíveis para consulta.
- **Busca** (topo): procura por adquirente, lote, contrato, empreendimento ou código.
- **Filtros rápidos** (menu lateral): para corrigir, em correção, corrigidos, atrasados.
- **Exportar CSV**: na tela de Distratos, gera uma planilha do que estiver filtrado.
- **Tipos de documento**: além de Distrato, dá para lançar Notificação extrajudicial,
  Rescisão, Aditivo ou Outro — é o mesmo controle de prazo.
- **Tema claro/escuro**: botão da lua, no topo.
