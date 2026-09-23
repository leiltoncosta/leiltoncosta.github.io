-- ============================================================================
--  CONTROLE DE DISTRATOS — Prazos Extrajudiciais (Loteamentos)
--  Leilton Costa Sociedade Individual de Advocacia
--
--  COMO USAR:
--  1. Crie um projeto novo em https://supabase.com  (anote a senha do banco)
--  2. Abra: SQL Editor  ->  New query
--  3. Cole ESTE ARQUIVO INTEIRO e clique em RUN
--  4. Depois vá em Authentication -> Users -> Add user e crie os logins
--     (um para a equipe e um para o Dr. Leilton), marcando "Auto Confirm User"
--  5. Em Project Settings -> API copie a "Project URL" e a chave "anon/public"
--     e cole na tela de configuração do sistema (index.html)
-- ============================================================================


-- ============================================================================
--  1. TABELAS
-- ============================================================================

-- Clientes / Loteamentos ------------------------------------------------------
create table if not exists public.clientes (
  id           uuid primary key default gen_random_uuid(),
  numero       bigint generated always as identity,
  nome         text not null,
  cnpj         text,
  tipo         text default 'Loteamento',      -- Loteamento | Construtora | Imobiliária | Outro
  responsavel  text,                           -- pessoa de contato no cliente
  telefone     text,
  email        text,
  cidade       text,
  uf           text,
  cor          text,                           -- cor de identificação na interface (hex)
  ativo        boolean not null default true,
  obs          text,
  criado_em    timestamptz not null default now(),
  criado_por   text
);

-- Distratos / documentos extrajudiciais ---------------------------------------
create table if not exists public.distratos (
  id                uuid primary key default gen_random_uuid(),
  numero            bigint generated always as identity,
  cliente_id        uuid not null references public.clientes(id) on delete cascade,

  tipo_documento    text not null default 'Distrato',   -- Distrato | Notificação extrajudicial | Rescisão | Aditivo | Outro
  empreendimento    text,                               -- nome do loteamento, quando o cliente tem vários
  quadra            text,
  lote              text,
  contrato          text,                               -- nº do contrato de compra e venda
  adquirente        text,                               -- nome do comprador / distratante
  cpf_adquirente    text,

  status            text not null default 'A corrigir', -- A corrigir | Em correção | Corrigido | Finalizado
  prioridade        text not null default 'Normal',     -- Normal | Urgente
  data_solicitacao  date  not null default current_date,
  prazo             date,                               -- prazo extrajudicial / data limite
  responsavel       text,                               -- quem elaborou a minuta

  arquivos          jsonb not null default '[]'::jsonb, -- [{id,tipo,path,nome,tamanho,enviado_em,enviado_por}]
  historico         jsonb not null default '[]'::jsonb, -- [{data,hora,quem,texto}]

  observacoes       text,   -- anotações da equipe
  parecer           text,   -- apontamentos do Dr. Leilton na correção

  criado_em         timestamptz not null default now(),
  criado_por        text,
  atualizado_em     timestamptz not null default now(),
  corrigido_em      timestamptz,
  corrigido_por     text,
  finalizado_em     timestamptz
);

create index if not exists distratos_cliente_idx  on public.distratos (cliente_id);
create index if not exists distratos_status_idx   on public.distratos (status);
create index if not exists distratos_prazo_idx    on public.distratos (prazo);


-- ============================================================================
--  2. PERMISSÕES
--     Só usuário logado lê/grava. O público (anon) não enxerga nada.
-- ============================================================================

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.clientes, public.distratos to authenticated;
revoke all on public.clientes, public.distratos from anon;

alter table public.clientes  enable row level security;
alter table public.distratos enable row level security;

drop policy if exists "somente logado" on public.clientes;
create policy "somente logado" on public.clientes
  for all to authenticated
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "somente logado" on public.distratos;
create policy "somente logado" on public.distratos
  for all to authenticated
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');


-- ============================================================================
--  3. ARMAZENAMENTO DOS ARQUIVOS (bucket privado "distratos")
--     Guarda o .docx/.pdf da minuta e a versão corrigida pelo Dr.
-- ============================================================================

insert into storage.buckets (id, name, public, file_size_limit)
values ('distratos', 'distratos', false, 26214400)   -- 25 MB por arquivo
on conflict (id) do update set file_size_limit = excluded.file_size_limit;

drop policy if exists "distratos_ler"     on storage.objects;
drop policy if exists "distratos_enviar"  on storage.objects;
drop policy if exists "distratos_alterar" on storage.objects;
drop policy if exists "distratos_apagar"  on storage.objects;

create policy "distratos_ler" on storage.objects
  for select to authenticated using (bucket_id = 'distratos');

create policy "distratos_enviar" on storage.objects
  for insert to authenticated with check (bucket_id = 'distratos');

create policy "distratos_alterar" on storage.objects
  for update to authenticated using (bucket_id = 'distratos');

create policy "distratos_apagar" on storage.objects
  for delete to authenticated using (bucket_id = 'distratos');


-- ============================================================================
--  4. ATUALIZA "atualizado_em" SOZINHO A CADA EDIÇÃO
-- ============================================================================

create or replace function public.toca_atualizado_em()
returns trigger language plpgsql as $$
begin
  new.atualizado_em = now();
  return new;
end $$;

drop trigger if exists distratos_toca_atualizado on public.distratos;
create trigger distratos_toca_atualizado
  before update on public.distratos
  for each row execute function public.toca_atualizado_em();


-- ============================================================================
--  PRONTO. Agora crie os usuários em Authentication -> Users.
-- ============================================================================

-- ============================================================================
--  5. TAREFAS EXTRAJUDICIAIS (diligencias: cartorio, prefeitura, etc.)
-- ============================================================================

create table if not exists public.tarefas (
  id            uuid primary key default gen_random_uuid(),
  numero        bigint generated always as identity,

  titulo        text not null,                       -- o que precisa ser feito
  local         text not null default 'Cartorio de Notas',
  orgao         text,                                -- qual cartorio/orgao especificamente
  endereco      text,

  cliente_id    uuid references public.clientes(id)  on delete set null,
  distrato_id   uuid references public.distratos(id) on delete set null,

  status        text not null default 'A fazer',     -- A fazer | Em andamento | Concluida | Cancelada
  prioridade    text not null default 'Normal',      -- Normal | Urgente
  data          date,                                -- quando ir / prazo
  hora          text,                                -- horario marcado, opcional
  responsavel   text,                                -- quem vai

  observacoes   text,
  resultado     text,                                -- protocolo, numero obtido, o que resultou

  arquivos      jsonb not null default '[]'::jsonb,
  historico     jsonb not null default '[]'::jsonb,

  criado_em     timestamptz not null default now(),
  criado_por    text,
  atualizado_em timestamptz not null default now(),
  concluida_em  timestamptz,
  concluida_por text
);

create index if not exists tarefas_status_idx  on public.tarefas (status);
create index if not exists tarefas_data_idx    on public.tarefas (data);
create index if not exists tarefas_cliente_idx on public.tarefas (cliente_id);

grant select, insert, update, delete on public.tarefas to authenticated;
revoke all on public.tarefas from anon;

alter table public.tarefas enable row level security;

drop policy if exists "somente logado" on public.tarefas;
create policy "somente logado" on public.tarefas
  for all to authenticated
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop trigger if exists tarefas_toca_atualizado on public.tarefas;
create trigger tarefas_toca_atualizado
  before update on public.tarefas
  for each row execute function public.toca_atualizado_em();

