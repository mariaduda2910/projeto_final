// sync_provider.dart (opcional) — o "termómetro"
//Responsabilidade: expor o estado da sincronização ao UI, para mostrares ícones tipo:

//🟢 "Tudo sincronizado"
//🟡 "A sincronizar..."
//🔴 "Offline — 3 alterações pendentes"
//O que tem:

//Subscreve ao ConnectivityService (online/offline)
//Subscreve a eventos do SyncService (a sincronizar / terminou / falhou)
//Expõe getters como estaOnline, aSincronizar, pendentes ao UI
//Sem este provider tudo funciona à mesma — só dá feedback visual.>