# Sorte Feita 🎯
> **Um app Feito Labs**  
> *Roletas, sorteios e equipes. Tudo grátis, sem cadastro.*

Repositório Oficial: [https://github.com/feitolabs/Sorte-Feita](https://github.com/feitolabs/Sorte-Feita)

---

## 🌟 Visão Geral

O **Sorte Feita** é uma plataforma completa e gratuita para criar e executar roletas, sorteios, divisões de grupos e decisões aleatórias. Desenvolvido para funcionar offline em sua plenitude, com total responsividade para **Android**, **iOS**, Web e Desktop.

### 🛡️ Princípios Fundamentais
- **100% Gratuito:** Sem planos pagos, assinaturas, compras internas ou moedas virtuais.
- **Sem Cadastro Obrigatório:** Pronto para uso imediato em qualquer dispositivo.
- **Privacidade & Local-First (LGPD):** Nomes e listas de participantes ficam armazenados exclusivamente no dispositivo do usuário (`localStorage`), sem envio de listas a terceiros ou publicidade.
- **Aleatoriedade Criptograficamente Segura (CSPRNG):** Uso de amostragem sem viés (rejection sampling), Fisher-Yates shuffle e seleção ponderada rigorosa, sem algoritmos ingênuos ou `Math.random`.
- **Publicidade Ética:** Anúncios nunca alteram resultados, nunca interrompem o giro da roleta e nunca cobrem ações críticas.
- **Segurança de Código:** Sem senhas hardcoded; uso estrito de variáveis de ambiente (`.env`).

---

## 🎨 Design System (Opção C · Tecnológica - Feito Labs)

- **Petróleo (`#0E3B43`):** Fundo escuro, títulos, botão principal.
- **Areia (`#F3EDE2`):** Fundo claro (tema padrão).
- **Azul Rio (`#1F7A8C`):** Destaques e acentos secundários.
- **Azul Rio Claro (`#5FB3C2`):** Destaque em fundo escuro.
- **Névoa (`#8FC1C9`):** Formas, bordas e segmentos da roleta.
- **Brasa (`#F26B21`):** Acento quente único por tela (Criar, Girar, Sortear, ponteiro da roleta).
- **Tipografia:** Google Fonts
  - **Bricolage Grotesque (400/800):** Títulos, números, logotipo, gomos da roleta.
  - **Hanken Grotesk (400/500/700):** Textos, controles e interface.

---

## 📱 Funcionalidades

1. **Abertura / Splash Screen:** Animação de duas etapas com marca Feito Labs e identidade Sorte Feita.
2. **Início (Home):**
   - Acesso rápido aos 3 grandes cartões: **Roleta**, **Nomes**, **Equipes**.
   - Barra de pesquisa em tempo real para ferramentas e modelos.
   - Seção de **Sorteios Recentes** com link para histórico.
   - Espaço de anúncio em conformidade com o escopo.
3. **Catálogo de Ferramentas:**
   - Filtros por categoria: *Todas*, *Roletas*, *Sorteios*, *Grupos*, *Decisões*.
   - 10 ferramentas completas:
     - 🎯 **Roleta:** Personalização com pesos diferentes, cores por gomo, remoção de vencedor após giro, animação com física e desaceleração real.
     - 📋 **Sorteio de Nomes:** Participantes por linha, detecção e remoção de nomes duplicados, contadores de ganhadores e suplentes, medalhas numeradas (1º, 2º, 3º).
     - 🔢 **Sorteio de Números:** Intervalo mínimo/máximo, quantidade, exclusões, repetição opcional e ordenação.
     - ⚽ **Equipes:** Divisão equilibrada, sorteio de capitães (★), reservas e cartões com temas coloridos.
     - 👥 **Duplas e Trios:** Resolução inteligente de sobras (par/trio).
     - 📝 **Tarefas:** Distribuição justa de tarefas entre pessoas.
     - ⚖️ **Sim ou Não:** Decisão rápida e oráculo com respostas personalizadas.
     - 🃏 **Cartas:** Baralho interativo com remoção e reposição.
     - 🔤 **Letras:** Gerador de letras do alfabeto A-Z.
     - ⭐ **Desafios:** Desafios leves, seguros e divertidos para festas e salas de aula.
4. **Histórico Local:**
   - Pesquisa por título, filtro por ferramenta, repetição de sorteio com novos dados, favoritos e exclusão segura com confirmação.
5. **Ajustes:**
   - Controle de efeitos sonoros, feedback tátil (haptic), redução de movimento (acessibilidade), política de privacidade LGPD e termos.

---

## 🏗️ Estrutura do Projeto

```
Sorte Feita/
├── backend/                  # Backend em Python (FastAPI + CSPRNG)
│   ├── app/
│   │   ├── api/v1/           # Endpoints: /wheel, /draws, /teams, /history, /templates
│   │   ├── core/             # CSPRNG, Security, Configurações
│   │   ├── models/           # Schemas Pydantic
│   │   └── services/         # Algoritmos de aleatoriedade e LocalStorage
│   ├── tests/                # Testes automatizados com Pytest (11/11 passando)
│   ├── requirements.txt      # Dependências Python
│   ├── .env.example          # Exemplo seguro de variáveis de ambiente
│   └── run.py                # Script de execução
│
├── frontend/                 # Frontend em Flutter (Android, iOS, Web, Desktop)
│   ├── lib/
│   │   ├── core/             # Tema, Cores, CSPRNG em Dart, LocalStorage
│   │   ├── models/           # Modelos de dados
│   │   ├── screens/          # Telas completas e responsivas
│   │   └── widgets/          # WheelPainter, AppNavbar, AdBannerPlaceholder
│   ├── assets/               # SVGs e imagens do design system
│   ├── test/                 # Testes de widget e unidade em Dart (5/5 passando)
│   └── pubspec.yaml          # Configurações do Flutter
│
├── SORTE FEITA CONTEXTO/     # Especificações originais, protótipos e diretrizes
└── pytest.ini                # Configuração do Pytest
```

---

## 🚀 Como Executar

### 1. Backend (Python)

```bash
# Entrar no diretório do backend
cd backend

# Instalar as dependências
pip install -r requirements.txt

# Executar os testes automatizados
pytest

# Iniciar o servidor FastAPI
python run.py
```
A documentação interativa Swagger estará disponível em: `http://localhost:8000/docs`.

---

### 2. Frontend (Flutter)

```bash
# Entrar no diretório do frontend
cd frontend

# Obter dependências
flutter pub get

# Executar os testes unitários e de widgets
flutter test

# Executar a aplicação (no dispositivo conectado, emulador ou navegador)
flutter run
```

---

## 🔒 Segurança e Boas Práticas

- Nenhuma chave de API ou senha está exposta no código.
- O arquivo `.env` está devidamente listado no `.gitignore`.
- Variáveis são gerenciadas via `pydantic-settings` no Python e `shared_preferences` no Flutter.
- Código 100% auditado por testes unitários e integrados.

