# 🏃 FITDay — Guia Completo de Deploy
### Do zero ao celular instalado em ~1 hora

---

## 📁 ESTRUTURA DE PASTAS DO PROJETO

```
fitday/
├── index.html          ← App principal (já pronto)
├── manifest.json       ← Configuração PWA (já pronto)
├── sw.js               ← Service Worker offline (já pronto)
├── database.sql        ← SQL do banco Supabase (já pronto)
├── icon-source.svg     ← Logo fonte para gerar ícones
└── icons/              ← Pasta que você vai criar
    ├── icon-72.png
    ├── icon-96.png
    ├── icon-128.png
    ├── icon-192.png    ← Ícone principal
    └── icon-512.png    ← Ícone splash/store
```

---

## PASSO 1 — Gerar os ícones PNG do app
*Tempo: ~5 minutos*

### 1.1 Acesse o gerador de ícones
Abra: **https://www.pwabuilder.com/imageGenerator**

### 1.2 Faça upload do arquivo `icon-source.svg`
- Clique em "Upload Image"
- Selecione o arquivo `icon-source.svg` que foi gerado

### 1.3 Configure o fundo
- Background color: `#1E293B`
- Padding: 10%
- Marque a opção **"Maskable"** (importante para Android)

### 1.4 Baixe e extraia
- Clique em "Download"
- Você receberá um ZIP com todos os tamanhos
- Extraia e renomeie os arquivos conforme a estrutura abaixo:

| Arquivo gerado | Renomear para |
|---|---|
| android/android-launchericon-72-72.png | `icons/icon-72.png` |
| android/android-launchericon-96-96.png | `icons/icon-96.png` |
| android/android-launchericon-128-128.png | `icons/icon-128.png` |
| android/android-launchericon-192-192.png | `icons/icon-192.png` |
| android/android-launchericon-512-512.png | `icons/icon-512.png` |

### 1.5 Crie a pasta icons/ no projeto
```
fitday/
└── icons/
    ├── icon-72.png
    ├── icon-96.png
    ├── icon-128.png
    ├── icon-192.png
    └── icon-512.png
```

> **Alternativa rápida:** Use https://favicon.io/favicon-converter ou
> https://realfavicongenerator.net — ambos aceitam SVG.

---

## PASSO 2 — Criar o projeto no Supabase
*Tempo: ~5 minutos*

### 2.1 Acesse e crie conta
Acesse **https://supabase.com** → "Start your project" → Login com GitHub.

### 2.2 Novo projeto
- Clique em **"New project"**
- Organization: sua conta pessoal
- **Name:** `fitday`
- **Database Password:** crie uma senha forte e SALVE em lugar seguro
- **Region:** `South America (São Paulo)` — sa-east-1
- Clique em **"Create new project"** e aguarde ~2 minutos

### 2.3 Pegue suas chaves de API
Após criar, vá em: **Settings → API**

Anote os dois valores:
```
Project URL:    https://XXXX.supabase.co
Anon Key:       eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
⚠️ A `anon key` é pública (safe para frontend). **Nunca exponha a `service_role` key.**

---

## PASSO 3 — Configurar o banco de dados
*Tempo: ~5 minutos*

### 3.1 Abra o SQL Editor
No painel Supabase: **SQL Editor → New query**

### 3.2 Cole e execute o SQL
- Abra o arquivo `database.sql`
- Selecione **todo o conteúdo** (Ctrl+A)
- Cole no SQL Editor
- Clique em **"Run"** (ou Ctrl+Enter)

Você deve ver: `Success. No rows returned`

### 3.3 Verifique as tabelas
Vá em **Table Editor** e confirme que estas tabelas foram criadas:
- `profiles`
- `walks`
- `habits`
- `habit_logs`
- `goals`

---

## PASSO 4 — Configurar autenticação
*Tempo: ~5 minutos*

### 4.1 Ativar Auth por Email
Vá em: **Authentication → Providers → Email**
- ✅ Enable Email provider: ON
- ✅ Confirm email: **OFF por enquanto** (facilita testes)
- Clique em **Save**

### 4.2 Configurar URL do site (após hospedar)
Vá em: **Authentication → URL Configuration**
- **Site URL:** `https://seu-usuario.github.io/fitday`
  (coloque o endereço real após hospedar no Passo 6)
- **Redirect URLs:** adicione o mesmo endereço + `http://localhost:3000`

---

## PASSO 5 — Conectar o app ao Supabase
*Tempo: ~5 minutos*

### 5.1 Adicione o SDK do Supabase no index.html
Abra `index.html` e adicione dentro do `<head>`, logo após o `<title>`:

```html
<!-- Supabase SDK -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
  const SUPABASE_URL  = 'https://XXXX.supabase.co';  // ← substitua
  const SUPABASE_KEY  = 'eyJhbGci...';               // ← substitua (anon key)
  const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
</script>
```

### 5.2 Substitua os valores
- `SUPABASE_URL` → seu Project URL do Passo 2.3
- `SUPABASE_KEY` → sua Anon Key do Passo 2.3

### 5.3 Teste a conexão
Abra o `index.html` em um servidor local:

**Opção A — VS Code Live Server:**
- Instale a extensão "Live Server" no VS Code
- Clique direito no `index.html` → "Open with Live Server"

**Opção B — Python (terminal):**
```bash
cd fitday
python -m http.server 3000
# Acesse http://localhost:3000
```

**Opção C — Node.js:**
```bash
npx serve fitday
```

Abra o console do browser (F12) e você deve ver o SW sendo registrado sem erros.

---

## PASSO 6 — Hospedar no GitHub Pages
*Tempo: ~10 minutos*

### 6.1 Crie um repositório no GitHub
- Acesse **github.com/Fiapinh1** (sua conta)
- Clique em **"New repository"**
- Name: `fitday`
- Visibility: **Public** (necessário para GitHub Pages grátis)
- Clique em **"Create repository"**

### 6.2 Suba os arquivos
```bash
# Na pasta do projeto
cd fitday

git init
git add .
git commit -m "FITDay - deploy inicial"
git branch -M main
git remote add origin https://github.com/Fiapinh1/fitday.git
git push -u origin main
```

### 6.3 Ativar GitHub Pages
- No repositório, vá em **Settings → Pages**
- Source: **"Deploy from a branch"**
- Branch: **main** / **(root)**
- Clique em **Save**
- Aguarde ~2 minutos
- Seu app estará em: `https://Fiapinh1.github.io/fitday`

### 6.4 Atualizar URL no manifest.json
Abra `manifest.json` e atualize:
```json
"start_url": "/fitday/",
"scope": "/fitday/"
```

### 6.5 Atualizar URL no Supabase Auth
Volte ao Passo 4.2 e adicione a URL real:
`https://Fiapinh1.github.io/fitday`

---

## PASSO 7 — Instalar no celular
*Tempo: ~2 minutos*

### Android (Chrome)
1. Abra `https://Fiapinh1.github.io/fitday` no Chrome
2. Aguarde o banner de instalação aparecer automaticamente
3. Toque em **"Instalar"**
4. O ícone FITDay aparecerá na sua tela inicial

**Alternativa manual no Android:**
- Toque no menu (⋮) → "Adicionar à tela inicial"

### iPhone/iPad (Safari)
1. Abra `https://Fiapinh1.github.io/fitday` no **Safari** (obrigatório)
2. Toque no botão **Compartilhar** (quadrado com seta)
3. Role para baixo e toque em **"Adicionar à Tela de Início"**
4. Confirme o nome **FITDay** e toque em **"Adicionar"**

> ⚠️ No iPhone, o PWA install só funciona no Safari. No Chrome iOS não aparece a opção.

---

## PASSO 8 — Verificar se o PWA está correto
*Tempo: ~3 minutos*

### 8.1 Chrome DevTools — Lighthouse
1. Abra o app no Chrome Desktop
2. F12 → aba **"Lighthouse"**
3. Selecione: Mobile + Progressive Web App
4. Clique em **"Analyze page load"**
5. A pontuação de **PWA deve ser 100%** ✅

### 8.2 Chrome DevTools — Application
- F12 → aba **"Application"**
- Veja em **"Manifest"**: deve mostrar seus ícones e nome
- Veja em **"Service Workers"**: deve mostrar `sw.js` como ativo
- Veja em **"Cache Storage"**: deve mostrar `fitday-v1`

---

## CHECKLIST FINAL — Tudo para funcionar hoje ✅

```
[ ] Pasta icons/ criada com os 5 arquivos PNG
[ ] Projeto Supabase criado na região São Paulo
[ ] SQL executado (5 tabelas criadas)
[ ] Email Auth ativado no Supabase
[ ] Variáveis SUPABASE_URL e SUPABASE_KEY no index.html
[ ] Repositório GitHub criado (Fiapinh1/fitday)
[ ] Arquivos enviados (git push)
[ ] GitHub Pages ativado
[ ] URL do site configurada no Supabase Auth
[ ] App aberto no celular e instalado
[ ] Lighthouse PWA Score ≥ 90
```

---

## PRÓXIMOS PASSOS (V1 completo)

Depois do deploy básico, as próximas implementações são:

1. **Tela de Login/Cadastro** — página separada com Supabase Auth
2. **Salvar caminhadas no banco** — substituir `saveWalk()` por insert no Supabase
3. **Carregar dados reais** — substituir dados estáticos por queries
4. **Marcar hábitos com persistência** — gravar em `habit_logs`
5. **Notificações push** — lembrete diário às 7h para marcar hábitos

---

## SUPORTE RÁPIDO — Erros comuns

| Erro | Causa | Solução |
|------|-------|---------|
| "SW não registrou" | Arquivo aberto via file:// | Usar Live Server / servidor local |
| "Manifest não encontrado" | Caminho errado | Confirmar que manifest.json está na raiz |
| "Ícone não aparece" | Pasta icons/ faltando | Criar a pasta e adicionar os PNGs |
| "Supabase connection refused" | URL/Key errada | Revisar variáveis no `<head>` do index.html |
| "RLS blocked" | Policies não criadas | Re-executar o database.sql completo |
| "PWA não instala no iPhone" | Usando Chrome iOS | Abrir no Safari |

---

*FITDay — Gerado em 19/04/2026*
