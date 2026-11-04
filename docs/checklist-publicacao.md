# Checklist de publicação (Android)

## 1. AdMob (admob.google.com)
- [ ] Criar app Android "Sorte Feita" → copiar **App ID** (`ca-app-pub-…~…`).
- [ ] Criar unidade **Banner** e **Intersticial** → copiar IDs.
- [ ] (iOS depois) repetir e trocar `GADApplicationIdentifier` em `frontend/ios/Runner/Info.plist`.
- [ ] Configurar mensagem de consentimento (Privacidade e mensagens › GDPR/UMP) e público geral (não infantil).

## 2. Keystore
```bash
bash scripts/gerar-keystore.sh
```
Guarde o `.jks` e as senhas em local seguro (se perder, não atualiza mais o app). Nunca commitar.

## 3. Play Console
- [ ] Criar app, idioma pt-BR, gratuito.
- [ ] Preencher listagem com `docs/loja-play-store.md`; hospedar a política e colar a URL.
- [ ] Segurança dos dados, classificação, declaração de anúncios.
- [ ] Monetizar › Produtos no app › criar `remove_ads` (gerenciado) e ativar.
- [ ] Configurar conta de pagamentos e **testadores de licença** (seu Gmail).

## 4. Build
```bash
ADMOB_APP_ID=ca-app-pub-XXX~YYY \
ADMOB_BANNER_ANDROID=ca-app-pub-XXX/AAA \
ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-XXX/BBB \
bash scripts/build-release.sh
```
Saída: `frontend/build/app/outputs/bundle/release/app-release.aab`.

## 5. Teste e lançamento
- [ ] Subir o .aab em **Teste interno**; instalar pelo link com a conta de testador.
- [ ] Verificar: anúncios carregam (use IDs de teste primeiro), compra de teste remove anúncios, restaurar compra, consentimento aparece (VPN UE), roleta sem anúncios.
- [ ] Teste fechado (Play exige 12 testadores por 14 dias para contas pessoais novas) → Produção.
- [ ] Trocar IDs de teste pelos reais **só no build final**; nunca clicar nos próprios anúncios reais.
