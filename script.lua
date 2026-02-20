-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                        SCRIPT BRAINROT                                  ║
-- ║                   Tsunami Brainhort  ·  v3.1.0                          ║
-- ╠══════════════════════════════════════════════════════════════════════════╣
-- ║  Author   :  ByteBandit_Ofici                                            ║
-- ║  Version  :  3.1.0                                                       ║
-- ║  Game     :  Tsunami Brainhort (Roblox)                                  ║
-- ║  Framework:  Rayfield by Sirius                                          ║
-- ╠══════════════════════════════════════════════════════════════════════════╣
-- ║  Changelog v3.1.0                                                        ║
-- ║   ADD  — Speed tab: slider 16–500 + 0.2s enforcement loop               ║
-- ║          Loop reapplies speed every 0.2s to fight game resets            ║
-- ║  Changelog v3.0.0                                                        ║
-- ║   FIX  — Removed BindToClose (server-only, caused crash on client)       ║
-- ║   FIX  — Wave loop no longer walks GetDescendants (was causing all lag)  ║
-- ║   FIX  — Settings theme now calls Rayfield:SetTheme() correctly          ║
-- ║   FIX  — Language selector applies immediately via live T() calls        ║
-- ║   ADD  — Teleport to Base tab (searches Ground / Baseplate / SpawnPart)  ║
-- ║   OPT  — ESP switched from SelectionBox to Highlight (much lighter)      ║
-- ║   OPT  — Wave interval raised to 1s to keep client smooth                ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

--==============================================================================
-- [1] SERVICES
--==============================================================================

local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local CoreGui           = game:GetService("CoreGui")

--==============================================================================
-- [2] PLAYER SHORTCUTS
--==============================================================================

local LP = Players.LocalPlayer

local function GetHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

--==============================================================================
-- [3] CONSTANTS
--==============================================================================

local META = {
    NAME    = "Script Brainrot",
    AUTHOR  = "ByteBandit_Ofici",
    VERSION = "3.1.0",
    GAME    = "Tsunami Brainhort",
    IMAGE   = 17617231460,
}

local BANNED_ID    = "adde680a-9773-4436-900b-614e07fd8362"
local VIP_NAME     = "VIPWalls"
local AB_FOLDER    = "ActiveBrainrots"
local WAVE_MIN     = 1
local WAVE_MAX     = 50
local WAVE_TICK    = 1.0   -- loop interval in seconds (safe for client FPS)
local KICK_DELAY   = 4.0   -- seconds to wait after PlayerAdded before scanning

-- Ground part names searched in order (most common first)
local GROUND_NAMES = { "Ground", "Baseplate", "Base", "SpawnPart", "Map" }

local RARITIES = {
    "Celestial", "Common",   "Cosmic",   "Divine",
    "Epic",      "Infinity", "Legendary","Mythical",
    "Rare",      "Secret",   "Uncommon",
}

local RARITY_COLOR = {
    Celestial  = Color3.fromRGB(255, 255, 110),
    Common     = Color3.fromRGB(190, 190, 190),
    Cosmic     = Color3.fromRGB(170,  90, 255),
    Divine     = Color3.fromRGB(255, 195,  40),
    Epic       = Color3.fromRGB(140,  40, 255),
    Infinity   = Color3.fromRGB(255, 255, 255),
    Legendary  = Color3.fromRGB(255, 135,   0),
    Mythical   = Color3.fromRGB(255,  45,  45),
    Rare       = Color3.fromRGB( 70, 125, 255),
    Secret     = Color3.fromRGB(  0, 250, 190),
    Uncommon   = Color3.fromRGB( 95, 215,  95),
}

-- Maps our theme display names → Rayfield's internal theme strings
-- (Rayfield built-in themes: Default, Ocean, Amethyst, Green, Light, Dark)
local THEME_MAP = {
    ["Black  (Default)"] = "Default",
    ["Ocean Blue"]       = "Ocean",
    ["Emerald Green"]    = "Green",
    ["Rose / Amethyst"]  = "Amethyst",
    ["Light"]            = "Light",
}
local THEME_KEYS = {
    "Black  (Default)",
    "Ocean Blue",
    "Emerald Green",
    "Rose / Amethyst",
    "Light",
}

--==============================================================================
-- [4] STATE
--==============================================================================

local S = {
    Lang         = "English",
    Theme        = "Black  (Default)",

    WaveLoop     = false,
    WaveThread   = nil,
    WavesTotal   = 0,

    AutoKick     = false,
    KickConn     = nil,
    KicksTotal   = 0,

    VIPDone      = false,

    Rarity       = "Common",
    Found        = {},
    ESPList      = {},
    ESPLabels    = true,
    Teleports    = 0,
    Searches     = 0,

    -- SPEED
    SpeedActive  = false,
    SpeedThread  = nil,
    SpeedValue   = 24,   -- default walkspeed (Roblox default = 16)
}

--==============================================================================
-- [5] LOCALIZATION  (English / Portuguese / Spanish)
--     T(key) is the only accessor — never hardcode UI strings below this block
--==============================================================================

local LANG = {}

------------------------------------------------------------------------
-- ENGLISH
------------------------------------------------------------------------
LANG.English = {
    -- tabs
    t_modgod   = "MOD GOD",
    t_vip      = "VIP FREE",
    t_auto     = "AUTO BRAINROT",
    t_base     = "TELEPORT BASE",
    t_credits  = "Credits",
    t_settings = "Settings",
    -- MOD GOD
    s_waves    = "Wave Management",
    s_players  = "Player Control",
    i_waves    = "Deletes Wave1_Visual → Wave50_Visual every second.",
    i_players  = "Scans and removes players carrying the banned item.",
    tog_wloop  = "Wave Delete Loop",
    tog_akick  = "Auto-Kick on Join",
    b_delwaves = "Delete All Waves Now",
    b_delplay  = "Remove Cheater Players",
    l_wstat    = "Waves destroyed this session: ",
    l_kstat    = "Players kicked this session: ",
    -- VIP
    s_vip      = "VIP Bypass",
    i_vip      = "Destroys the VIPWalls model — grants free VIP access.",
    b_vip      = "Remove VIP Walls",
    l_vipstat  = "VIP Walls: ",
    l_vip_on   = "PRESENT",
    l_vip_off  = "REMOVED",
    -- AUTO BRAINROT
    s_scan     = "Brainrot Scanner",
    s_tp       = "Teleportation",
    s_esp      = "ESP Controls",
    i_scan     = "Scans ActiveBrainrots for the chosen rarity tier.",
    d_rarity   = "Select Rarity",
    b_search   = "Search for Brainrots",
    b_tp       = "Teleport to Random Brainrot",
    b_espclear = "Clear ESP",
    b_espref   = "Refresh ESP",
    tog_labels = "Show Name Labels",
    l_hint     = "Pick a rarity then press Search.",
    l_tpcount  = "Teleports: ",
    l_srcount  = "Searches: ",
    -- TELEPORT BASE
    s_base     = "Base Teleporter",
    i_base     = "Instantly warps you to the Ground part of the map.",
    i_base2    = "Searches for: Ground · Baseplate · Base · SpawnPart",
    b_base     = "Teleport to Ground",
    -- CREDITS
    s_cred     = "Script Brainrot",
    s_build    = "Build Info",
    s_feat     = "Features",
    l_author   = "Author",
    l_version  = "Version",
    l_game     = "Game",
    l_fw       = "GUI Framework",
    l_fw_val   = "Rayfield by Sirius",
    f1         = "MOD GOD — Wave delete loop + cheater removal",
    f2         = "VIP FREE — Instant VIPWalls bypass",
    f3         = "AUTO BRAINROT — Rarity ESP + random teleport",
    f4         = "TELEPORT BASE — One-click Ground teleport",
    f5         = "Multi-Language — English / Portuguese / Spanish",
    f6         = "Themes — Black / Ocean Blue / Emerald / Rose",
    -- SETTINGS
    s_lang     = "Language",
    s_theme    = "Theme",
    s_misc     = "Miscellaneous",
    d_lang     = "Interface Language",
    d_theme    = "Color Theme",
    i_lang     = "Language updates apply to new labels immediately.",
    i_theme    = "Theme applied instantly via Rayfield SetTheme.",
    b_reset    = "Reset Session Stats",
    -- NOTIFICATIONS
    n_load_t   = "Script Brainrot Loaded",
    n_load_b   = "Welcome, ",
    n_wclr_t   = "Waves Cleared",
    n_wclr_b   = "Wave visuals removed: ",
    n_wnone    = "No wave visuals found in the workspace.",
    n_kick_t   = "Cheaters Removed",
    n_kick_b   = " player(s) removed from the server.",
    n_knone    = "No cheating players detected on this server.",
    n_vip_t    = "VIP Walls Removed",
    n_vip_b    = "VIPWalls destroyed. Free VIP access granted.",
    n_vnone    = "VIPWalls model not found.",
    n_fnd_t    = "Brainrots Found!",
    n_fnd_b    = "ESP active — objects found in rarity: ",
    n_nfnd_t   = "Nothing Found",
    n_nfnd_b   = "No objects in the selected rarity folder.",
    n_tp_t     = "Teleported!",
    n_tp_b     = "Jumped to a Brainrot in: ",
    n_tpf      = "Teleport failed — no valid position found.",
    n_ec_t     = "ESP Cleared",
    n_ec_b     = "All ESP highlights and labels removed.",
    n_er_t     = "ESP Refreshed",
    n_er_b     = "Highlights re-applied to ",
    n_base_t   = "Teleported to Base",
    n_base_b   = "Landed on: ",
    n_basef    = "Ground part not found in the workspace.",
    n_lang_t   = "Language Updated",
    n_lang_b   = "Set to English.",
    n_thm_t    = "Theme Updated",
    n_thm_b    = "Theme applied successfully.",
    n_rst_t    = "Stats Reset",
    n_rst_b    = "Session counters cleared.",
    n_lon_t    = "Wave Loop ON",
    n_lon_b    = "Deleting waves every 1 second.",
    n_loff_t   = "Wave Loop OFF",
    n_loff_b   = "Wave loop stopped.",
    n_akon_t   = "Auto-Kick ON",
    n_akon_b   = "New cheaters will be removed on join.",
    n_akoff_t  = "Auto-Kick OFF",
    n_akoff_b  = "Incoming players will not be scanned.",
    -- SPEED
    t_speed    = "SPEED",
    s_speed    = "Speed Hack",
    i_speed    = "Enforces your WalkSpeed every 0.2s to resist game resets.",
    tog_speed  = "Enable Speed Loop",
    sl_speed   = "WalkSpeed Value",
    b_spd_def  = "Reset to Default (16)",
    l_spd_cur  = "Current target speed: ",
    n_spon_t   = "Speed Loop ON",
    n_spon_b   = "Applying WalkSpeed every 0.2s.",
    n_spoff_t  = "Speed Loop OFF",
    n_spoff_b  = "Speed loop stopped. Speed returned to 16.",
    n_sprst_t  = "Speed Reset",
    n_sprst_b  = "WalkSpeed returned to default (16).",
}

------------------------------------------------------------------------
-- PORTUGUESE
------------------------------------------------------------------------
LANG.Portuguese = {
    t_modgod   = "MOD DEUS",
    t_vip      = "VIP GRÁTIS",
    t_auto     = "AUTO BRAINROT",
    t_base     = "TELEPORTE BASE",
    t_credits  = "Créditos",
    t_settings = "Configurações",
    s_waves    = "Gerenciar Ondas",
    s_players  = "Controle de Jogadores",
    i_waves    = "Deleta Wave1_Visual → Wave50_Visual a cada segundo.",
    i_players  = "Escaneia e remove jogadores com o item banido.",
    tog_wloop  = "Loop de Deletar Ondas",
    tog_akick  = "Auto-Expulsar ao Entrar",
    b_delwaves = "Deletar Todas as Ondas Agora",
    b_delplay  = "Remover Jogadores Trapaceiros",
    l_wstat    = "Ondas destruídas nesta sessão: ",
    l_kstat    = "Jogadores expulsos nesta sessão: ",
    s_vip      = "Bypass VIP",
    i_vip      = "Destrói o modelo VIPWalls — dá acesso VIP grátis.",
    b_vip      = "Remover Paredes VIP",
    l_vipstat  = "Paredes VIP: ",
    l_vip_on   = "PRESENTE",
    l_vip_off  = "REMOVIDO",
    s_scan     = "Scanner de Brainrot",
    s_tp       = "Teletransporte",
    s_esp      = "Controles ESP",
    i_scan     = "Escaneia ActiveBrainrots pela raridade selecionada.",
    d_rarity   = "Selecionar Raridade",
    b_search   = "Procurar Brainrots",
    b_tp       = "Teleportar para Brainrot Aleatório",
    b_espclear = "Limpar ESP",
    b_espref   = "Atualizar ESP",
    tog_labels = "Mostrar Nomes",
    l_hint     = "Escolha uma raridade e pressione Procurar.",
    l_tpcount  = "Teleportes: ",
    l_srcount  = "Pesquisas: ",
    s_base     = "Teleportador de Base",
    i_base     = "Teletransporta instantaneamente para a part Ground do mapa.",
    i_base2    = "Procura por: Ground · Baseplate · Base · SpawnPart",
    b_base     = "Teleportar para o Ground",
    s_cred     = "Script Brainrot",
    s_build    = "Informações de Build",
    s_feat     = "Recursos",
    l_author   = "Autor",
    l_version  = "Versão",
    l_game     = "Jogo",
    l_fw       = "Framework GUI",
    l_fw_val   = "Rayfield por Sirius",
    f1         = "MOD DEUS — Loop de ondas + remoção de trapaceiros",
    f2         = "VIP GRÁTIS — Bypass instantâneo do VIPWalls",
    f3         = "AUTO BRAINROT — ESP de raridade + teleporte aleatório",
    f4         = "TELEPORTE BASE — Teleporte Ground com um clique",
    f5         = "Multi-Idioma — Inglês / Português / Espanhol",
    f6         = "Temas — Preto / Azul Oceano / Esmeralda / Rosa",
    s_lang     = "Idioma",
    s_theme    = "Tema",
    s_misc     = "Outros",
    d_lang     = "Idioma da Interface",
    d_theme    = "Tema de Cores",
    i_lang     = "A mudança de idioma aplica instantaneamente.",
    i_theme    = "Tema aplicado instantaneamente via Rayfield SetTheme.",
    b_reset    = "Resetar Estatísticas",
    n_load_t   = "Script Brainrot Carregado",
    n_load_b   = "Bem-vindo, ",
    n_wclr_t   = "Ondas Destruídas",
    n_wclr_b   = "Visuais removidos: ",
    n_wnone    = "Nenhum visual de onda encontrado.",
    n_kick_t   = "Trapaceiros Removidos",
    n_kick_b   = " jogador(es) removido(s).",
    n_knone    = "Nenhum trapaceiro detectado neste servidor.",
    n_vip_t    = "Paredes VIP Removidas",
    n_vip_b    = "VIPWalls destruído. Acesso VIP grátis concedido.",
    n_vnone    = "Modelo VIPWalls não encontrado.",
    n_fnd_t    = "Brainrots Encontrados!",
    n_fnd_b    = "ESP ativo — objetos encontrados em: ",
    n_nfnd_t   = "Nada Encontrado",
    n_nfnd_b   = "Nenhum objeto na pasta de raridade selecionada.",
    n_tp_t     = "Teleportado!",
    n_tp_b     = "Saltou para Brainrot em: ",
    n_tpf      = "Falha no teleporte — nenhuma posição válida.",
    n_ec_t     = "ESP Limpo",
    n_ec_b     = "Todos os destaques e labels removidos.",
    n_er_t     = "ESP Atualizado",
    n_er_b     = "Destaques reaplicados em ",
    n_base_t   = "Teleportado para a Base",
    n_base_b   = "Pousou em: ",
    n_basef    = "Part Ground não encontrada no workspace.",
    n_lang_t   = "Idioma Atualizado",
    n_lang_b   = "Definido para Português.",
    n_thm_t    = "Tema Atualizado",
    n_thm_b    = "Tema aplicado com sucesso.",
    n_rst_t    = "Stats Resetados",
    n_rst_b    = "Todos os contadores da sessão foram zerados.",
    n_lon_t    = "Loop de Ondas ATIVO",
    n_lon_b    = "Deletando ondas a cada 1 segundo.",
    n_loff_t   = "Loop de Ondas PARADO",
    n_loff_b   = "Loop de ondas desativado.",
    n_akon_t   = "Auto-Expulsão ATIVA",
    n_akon_b   = "Novos trapaceiros serão removidos ao entrar.",
    n_akoff_t  = "Auto-Expulsão DESATIVADA",
    n_akoff_b  = "Jogadores não serão escaneados.",
    -- SPEED
    t_speed    = "VELOCIDADE",
    s_speed    = "Speed Hack",
    i_speed    = "Força seu WalkSpeed a cada 0.2s para resistir aos resets do jogo.",
    tog_speed  = "Ativar Loop de Velocidade",
    sl_speed   = "Valor do WalkSpeed",
    b_spd_def  = "Resetar para Padrão (16)",
    l_spd_cur  = "Velocidade alvo atual: ",
    n_spon_t   = "Loop de Velocidade ATIVO",
    n_spon_b   = "Aplicando WalkSpeed a cada 0.2s.",
    n_spoff_t  = "Loop de Velocidade PARADO",
    n_spoff_b  = "Loop parado. Velocidade retornada para 16.",
    n_sprst_t  = "Velocidade Resetada",
    n_sprst_b  = "WalkSpeed retornado ao padrão (16).",
}

------------------------------------------------------------------------
-- SPANISH
------------------------------------------------------------------------
LANG.Spanish = {
    t_modgod   = "MOD DIOS",
    t_vip      = "VIP GRATIS",
    t_auto     = "AUTO BRAINROT",
    t_base     = "TELEPORTE BASE",
    t_credits  = "Créditos",
    t_settings = "Configuración",
    s_waves    = "Gestión de Olas",
    s_players  = "Control de Jugadores",
    i_waves    = "Elimina Wave1_Visual → Wave50_Visual cada segundo.",
    i_players  = "Escanea y elimina jugadores con el ítem prohibido.",
    tog_wloop  = "Bucle de Eliminación de Olas",
    tog_akick  = "Auto-Expulsar al Unirse",
    b_delwaves = "Eliminar Todas las Olas Ahora",
    b_delplay  = "Eliminar Jugadores Tramposos",
    l_wstat    = "Olas destruidas en esta sesión: ",
    l_kstat    = "Jugadores expulsados en esta sesión: ",
    s_vip      = "Bypass VIP",
    i_vip      = "Destruye el modelo VIPWalls — otorga VIP gratis.",
    b_vip      = "Eliminar Muros VIP",
    l_vipstat  = "Muros VIP: ",
    l_vip_on   = "PRESENTE",
    l_vip_off  = "ELIMINADO",
    s_scan     = "Escáner de Brainrot",
    s_tp       = "Teletransportación",
    s_esp      = "Controles ESP",
    i_scan     = "Escanea ActiveBrainrots por nivel de rareza.",
    d_rarity   = "Seleccionar Rareza",
    b_search   = "Buscar Brainrots",
    b_tp       = "Teletransportar a Brainrot Aleatorio",
    b_espclear = "Limpiar ESP",
    b_espref   = "Actualizar ESP",
    tog_labels = "Mostrar Etiquetas",
    l_hint     = "Elige una rareza y pulsa Buscar.",
    l_tpcount  = "Teletransportes: ",
    l_srcount  = "Búsquedas: ",
    s_base     = "Teletransportador de Base",
    i_base     = "Te teletransporta instantáneamente a la part Ground del mapa.",
    i_base2    = "Busca: Ground · Baseplate · Base · SpawnPart",
    b_base     = "Teletransportar al Ground",
    s_cred     = "Script Brainrot",
    s_build    = "Info de Build",
    s_feat     = "Características",
    l_author   = "Autor",
    l_version  = "Versión",
    l_game     = "Juego",
    l_fw       = "Framework GUI",
    l_fw_val   = "Rayfield por Sirius",
    f1         = "MOD DIOS — Bucle de olas + eliminación de tramposos",
    f2         = "VIP GRATIS — Bypass instantáneo de VIPWalls",
    f3         = "AUTO BRAINROT — ESP por rareza + teletransporte aleatorio",
    f4         = "TELEPORTE BASE — Teletransporte Ground con un clic",
    f5         = "Multi-Idioma — Inglés / Portugués / Español",
    f6         = "Temas — Negro / Azul Océano / Esmeralda / Rosa",
    s_lang     = "Idioma",
    s_theme    = "Tema",
    s_misc     = "Varios",
    d_lang     = "Idioma de Interfaz",
    d_theme    = "Tema de Colores",
    i_lang     = "El cambio de idioma se aplica al instante.",
    i_theme    = "El tema se aplica al instante via Rayfield SetTheme.",
    b_reset    = "Reiniciar Estadísticas",
    n_load_t   = "Script Brainrot Cargado",
    n_load_b   = "Bienvenido, ",
    n_wclr_t   = "Olas Eliminadas",
    n_wclr_b   = "Visuales eliminados: ",
    n_wnone    = "No se encontraron visuales de olas.",
    n_kick_t   = "Tramposos Eliminados",
    n_kick_b   = " jugador(es) eliminado(s).",
    n_knone    = "No se detectaron tramposos en el servidor.",
    n_vip_t    = "Muros VIP Eliminados",
    n_vip_b    = "VIPWalls destruido. ¡VIP gratis concedido!",
    n_vnone    = "Modelo VIPWalls no encontrado.",
    n_fnd_t    = "¡Brainrots Encontrados!",
    n_fnd_b    = "ESP activo — objetos en rareza: ",
    n_nfnd_t   = "No Encontrado",
    n_nfnd_b   = "No hay objetos en la carpeta de rareza.",
    n_tp_t     = "¡Teletransportado!",
    n_tp_b     = "Saltaste a un Brainrot en: ",
    n_tpf      = "Fallo — no se encontraron posiciones válidas.",
    n_ec_t     = "ESP Limpiado",
    n_ec_b     = "Todos los resaltados y etiquetas eliminados.",
    n_er_t     = "ESP Actualizado",
    n_er_b     = "Resaltados reaplicados en ",
    n_base_t   = "Teletransportado a la Base",
    n_base_b   = "Aterrizaste en: ",
    n_basef    = "Part Ground no encontrada en el workspace.",
    n_lang_t   = "Idioma Actualizado",
    n_lang_b   = "Configurado a Español.",
    n_thm_t    = "Tema Actualizado",
    n_thm_b    = "Tema aplicado correctamente.",
    n_rst_t    = "Stats Reiniciados",
    n_rst_b    = "Contadores de sesión borrados.",
    n_lon_t    = "Bucle de Olas ACTIVADO",
    n_lon_b    = "Eliminando olas cada 1 segundo.",
    n_loff_t   = "Bucle de Olas DETENIDO",
    n_loff_b   = "Bucle de eliminación detenido.",
    n_akon_t   = "Auto-Expulsión ACTIVADA",
    n_akon_b   = "Tramposos nuevos serán eliminados al entrar.",
    n_akoff_t  = "Auto-Expulsión DESACTIVADA",
    n_akoff_b  = "Los jugadores no serán escaneados.",
    -- SPEED
    t_speed    = "VELOCIDAD",
    s_speed    = "Speed Hack",
    i_speed    = "Fuerza tu WalkSpeed cada 0.2s para resistir los resets del juego.",
    tog_speed  = "Activar Bucle de Velocidad",
    sl_speed   = "Valor de WalkSpeed",
    b_spd_def  = "Resetear a Predeterminado (16)",
    l_spd_cur  = "Velocidad objetivo actual: ",
    n_spon_t   = "Bucle de Velocidad ACTIVADO",
    n_spon_b   = "Aplicando WalkSpeed cada 0.2s.",
    n_spoff_t  = "Bucle de Velocidad DETENIDO",
    n_spoff_b  = "Bucle detenido. Velocidad devuelta a 16.",
    n_sprst_t  = "Velocidad Reseteada",
    n_sprst_b  = "WalkSpeed devuelto al predeterminado (16).",
}

-- T(key) — translation accessor, always falls back to English
local function T(k)
    local tbl = LANG[S.Lang] or LANG.English
    return tbl[k] or LANG.English[k] or ("[?"..k.."?]")
end

--==============================================================================
-- [6] UTILITIES
--==============================================================================

local function Safe(fn, ...)
    return pcall(fn, ...)
end

local function ObjPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local p = obj:FindFirstChildWhichIsA("BasePart")
        if p then return p.Position end
        -- bounding box fallback
        local ok, cf = Safe(function() return obj:GetBoundingBox() end)
        if ok and cf then return cf.Position end
    end
    return nil
end

local function WarpTo(pos, yOffset)
    local hrp = GetHRP()
    if not hrp or not pos then return false end
    Safe(function()
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, yOffset or 5, 0))
    end)
    return true
end

--==============================================================================
-- [7] WAVE ENGINE
-- CRITICAL FIX: Only uses FindFirstChild (O(1) hash lookup per name).
-- The old version walked ALL descendants every 0.4 s — that was the lag.
--==============================================================================

local function SweepWaves()
    local n = 0
    for i = WAVE_MIN, WAVE_MAX do
        -- FindFirstChild with NO second argument = direct children only, very fast
        local obj = Workspace:FindFirstChild("Wave" .. i .. "_Visual")
        if obj then
            Safe(function() obj:Destroy() end)
            n = n + 1
        end
    end
    S.WavesTotal = S.WavesTotal + n
    return n
end

local function StartWaveLoop()
    S.WaveLoop   = true
    S.WaveThread = task.spawn(function()
        while S.WaveLoop do
            Safe(SweepWaves)
            task.wait(WAVE_TICK) -- task.wait never blocks the render thread
        end
    end)
end

local function StopWaveLoop()
    S.WaveLoop   = false
    S.WaveThread = nil
end

--==============================================================================
-- [8] CHEATER DETECTION
--==============================================================================

local function IsBanned(item)
    local id = BANNED_ID:lower()
    if tostring(item.Name):lower():find(id, 1, true) then return true end
    for _, a in ipairs({"ItemId","AssetId","Id","UUID","UID"}) do
        local v = item:GetAttribute(a)
        if v and tostring(v):lower() == id then return true end
    end
    if CollectionService:HasTag(item, BANNED_ID) then return true end
    return false
end

local function HasBannedItem(player)
    if player == LP then return false end
    local checks = {}
    local bp = player:FindFirstChild("Backpack")
    if bp then table.insert(checks, bp) end
    if player.Character then table.insert(checks, player.Character) end
    for _, cont in ipairs(checks) do
        for _, item in ipairs(cont:GetChildren()) do
            if IsBanned(item) then return true end
        end
    end
    return false
end

local function KickPlayer(player)
    if player == LP then return false end
    local done = false
    Safe(function() player:Kick("[Script Brainrot] Banned item."); done = true end)
    if not done then
        Safe(function()
            if player.Character then player.Character:Destroy(); done = true end
        end)
    end
    if done then S.KicksTotal = S.KicksTotal + 1 end
    return done
end

local function ScanCurrentPlayers()
    local n = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and HasBannedItem(p) then
            if KickPlayer(p) then n = n + 1 end
        end
    end
    return n
end

local function StartAutoKick()
    S.AutoKick = true
    S.KickConn = Players.PlayerAdded:Connect(function(player)
        -- Run check in its own thread — never blocks PlayerAdded
        task.spawn(function()
            task.wait(KICK_DELAY)
            if S.AutoKick and HasBannedItem(player) then
                KickPlayer(player)
            end
        end)
    end)
end

local function StopAutoKick()
    S.AutoKick = false
    if S.KickConn then
        Safe(function() S.KickConn:Disconnect() end)
        S.KickConn = nil
    end
end

--==============================================================================
-- [9] VIP BYPASS
--==============================================================================

local function RemoveVIPWalls()
    local n = 0
    for _, root in ipairs({Workspace, ReplicatedStorage}) do
        Safe(function()
            -- recursive=true to catch nested VIPWalls
            local obj = root:FindFirstChild(VIP_NAME, true)
            if obj then obj:Destroy(); n = n + 1 end
        end)
    end
    if n > 0 then S.VIPDone = true end
    return n > 0, n
end

--==============================================================================
-- [10] BASE TELEPORTER
-- Searches GROUND_NAMES in Workspace direct children first (fastest),
-- then falls back to recursive search.
--==============================================================================

local function FindGroundPart()
    for _, name in ipairs(GROUND_NAMES) do
        local obj = Workspace:FindFirstChild(name)
        if obj then return obj, name end
    end
    for _, name in ipairs(GROUND_NAMES) do
        local obj = Workspace:FindFirstChild(name, true)
        if obj then return obj, name end
    end
    return nil, nil
end

local function TeleportToBase()
    local obj, name = FindGroundPart()
    if not obj then return false, nil end
    local pos = ObjPos(obj)
    if not pos then return false, nil end
    local ok = WarpTo(pos, 4)
    return ok, name
end

--==============================================================================
-- [11] SPEED ENGINE
-- The game resets WalkSpeed constantly (on respawn, on wave events, etc.)
-- Fix: 0.2s task.spawn loop that grabs the Humanoid fresh every tick and
-- overwrites WalkSpeed — this beats any server-side reset timing.
-- CharacterAdded hook ensures the loop auto-recovers after death/respawn.
--==============================================================================

local SPEED_TICK = 0.2  -- enforcement interval (seconds)

-- Applies target speed to local Humanoid right now.
local function ApplySpeed(targetSpeed)
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    Safe(function() hum.WalkSpeed = targetSpeed end)
    return true
end

-- Resets WalkSpeed back to Roblox default.
local function ResetSpeed()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then Safe(function() hum.WalkSpeed = 16 end) end
end

-- Starts the 0.2s enforcement loop.
local function StartSpeedLoop()
    S.SpeedActive = true
    S.SpeedThread = task.spawn(function()
        while S.SpeedActive do
            ApplySpeed(S.SpeedValue)
            task.wait(SPEED_TICK)
        end
    end)
end

-- Stops the loop and restores default speed.
local function StopSpeedLoop()
    S.SpeedActive = false
    S.SpeedThread = nil
    ResetSpeed()
end

-- Auto-recover speed after respawn / character reload.
LP.CharacterAdded:Connect(function()
    if S.SpeedActive then
        task.wait(0.15)  -- wait for Humanoid to fully initialize
        ApplySpeed(S.SpeedValue)
    end
end)

--==============================================================================
-- [12] ESP SYSTEM
-- FIX: Uses Highlight (introduced 2022) instead of SelectionBox.
-- Highlight renders in a single GPU pass; SelectionBox recalculates every
-- surface boundary every frame — with many objects that was a major cost.
--==============================================================================

local function ClearESP()
    for _, h in ipairs(S.ESPList) do
        Safe(function() h:Destroy() end)
    end
    S.ESPList = {}
end

local function ApplyESP(objects, rarity)
    ClearESP()
    local col = RARITY_COLOR[rarity] or Color3.fromRGB(255, 255, 255)

    for _, obj in ipairs(objects) do
        Safe(function()
            -- Highlight instance: single draw call, always-on-top capable
            local h        = Instance.new("Highlight")
            h.Adornee      = obj
            h.FillColor    = col
            h.OutlineColor = col
            h.FillTransparency    = 0.65
            h.OutlineTransparency = 0.0
            h.DepthMode    = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent       = CoreGui
            table.insert(S.ESPList, h)

            -- Optional floating label
            if S.ESPLabels then
                local adornee = obj
                if obj:IsA("Model") then
                    adornee = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                end
                if adornee and adornee:IsA("BasePart") then
                    local bg        = Instance.new("BillboardGui")
                    bg.Adornee      = adornee
                    bg.Size         = UDim2.new(0, 160, 0, 28)
                    bg.StudsOffset  = Vector3.new(0, 4, 0)
                    bg.AlwaysOnTop  = true
                    bg.LightInfluence = 0
                    bg.Parent       = CoreGui
                    table.insert(S.ESPList, bg)

                    local lbl              = Instance.new("TextLabel")
                    lbl.Size               = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3         = col
                    lbl.TextStrokeTransparency = 0.25
                    lbl.TextStrokeColor3   = Color3.new(0,0,0)
                    lbl.Font               = Enum.Font.GothamBold
                    lbl.TextSize           = 13
                    lbl.Text               = "[" .. rarity:upper() .. "]  " .. obj.Name
                    lbl.Parent             = bg
                end
            end
        end)
    end
end

--==============================================================================
-- [12] BRAINROT SCANNER
--==============================================================================

local function FindBrainrotsRoot()
    for _, root in ipairs({Workspace, ReplicatedStorage}) do
        local f = root:FindFirstChild(AB_FOLDER)
        if f then return f end
        f = root:FindFirstChild(AB_FOLDER, true)
        if f then return f end
    end
    return nil
end

local function FindRarityFolder(root, rarity)
    local exact = root:FindFirstChild(rarity)
    if exact then return exact end
    local low = rarity:lower()
    for _, child in ipairs(root:GetChildren()) do
        if child.Name:lower() == low then return child end
    end
    return nil
end

local function SearchBrainrots(rarity)
    S.Found    = {}
    S.Searches = S.Searches + 1

    local root = FindBrainrotsRoot()
    if not root then return false, 0 end

    local folder = FindRarityFolder(root, rarity)
    if not folder then return false, 0 end

    local objs = folder:GetChildren()
    if #objs == 0 then
        -- Try one level deeper
        for _, sub in ipairs(folder:GetDescendants()) do
            if sub:IsA("Model") or sub:IsA("BasePart") then
                table.insert(objs, sub)
            end
        end
    end

    if #objs == 0 then return false, 0 end

    S.Found = objs
    ApplyESP(objs, rarity)
    return true, #objs
end

local function TeleportToRandom()
    if #S.Found == 0 then return false, nil end
    local target = S.Found[math.random(1, #S.Found)]
    local pos    = ObjPos(target)
    if not pos then return false, nil end
    local ok = WarpTo(pos, 5)
    if ok then S.Teleports = S.Teleports + 1 end
    return ok, target.Name
end

--==============================================================================
-- [13] LOAD RAYFIELD
--==============================================================================

local Rayfield
local ok, err = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not ok or not Rayfield then
    -- Graceful fallback — notify without crashing
    Safe(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = "Script Brainrot — Load Error",
            Text     = "Could not load Rayfield. Enable HTTP Requests in your executor.",
            Duration = 8,
        })
    end)
    return  -- stop execution here cleanly
end

--==============================================================================
-- [14] WINDOW
--==============================================================================

local Win = Rayfield:CreateWindow({
    Name                   = META.NAME,
    Icon                   = META.IMAGE,
    LoadingTitle           = META.NAME,
    LoadingSubtitle        = "by " .. META.AUTHOR .. "  ·  v" .. META.VERSION,
    Theme                  = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = true,
    ConfigurationSaving    = { Enabled = false },
    KeySystem              = false,
})

-- Shorthand notify
local function Notify(title, body, dur, img)
    Rayfield:Notify({
        Title    = title,
        Content  = body,
        Duration = dur or 4,
        Image    = img or 4483362458,
    })
end

--==============================================================================
-- [15] TAB: MOD GOD
--==============================================================================

local TabGod = Win:CreateTab(T("t_modgod"), "shield")

TabGod:CreateSection(T("s_waves"))
TabGod:CreateLabel(T("i_waves"))

TabGod:CreateToggle({
    Name         = T("tog_wloop"),
    CurrentValue = false,
    Flag         = "WaveLoop",
    Callback     = function(v)
        if v then
            StartWaveLoop()
            Notify(T("n_lon_t"), T("n_lon_b"))
        else
            StopWaveLoop()
            Notify(T("n_loff_t"), T("n_loff_b"), 4, 4483347087)
        end
    end,
})

TabGod:CreateButton({
    Name     = T("b_delwaves"),
    Callback = function()
        local n = SweepWaves()
        if n > 0 then
            Notify(T("n_wclr_t"), T("n_wclr_b") .. n)
        else
            Notify(T("n_wclr_t"), T("n_wnone"), 4, 4483347087)
        end
    end,
})

TabGod:CreateLabel(T("l_wstat") .. tostring(S.WavesTotal))

TabGod:CreateDivider()

TabGod:CreateSection(T("s_players"))
TabGod:CreateLabel(T("i_players"))

TabGod:CreateToggle({
    Name         = T("tog_akick"),
    CurrentValue = false,
    Flag         = "AutoKick",
    Callback     = function(v)
        if v then
            StartAutoKick()
            Notify(T("n_akon_t"), T("n_akon_b"))
        else
            StopAutoKick()
            Notify(T("n_akoff_t"), T("n_akoff_b"), 4, 4483347087)
        end
    end,
})

TabGod:CreateButton({
    Name     = T("b_delplay"),
    Callback = function()
        local n = ScanCurrentPlayers()
        if n > 0 then
            Notify(T("n_kick_t"), tostring(n) .. T("n_kick_b"))
        else
            Notify(T("n_kick_t"), T("n_knone"), 4, 4483347087)
        end
    end,
})

TabGod:CreateLabel(T("l_kstat") .. tostring(S.KicksTotal))

--==============================================================================
-- [16] TAB: VIP FREE
--==============================================================================

local TabVIP = Win:CreateTab(T("t_vip"), "crown")

TabVIP:CreateSection(T("s_vip"))
TabVIP:CreateLabel(T("i_vip"))

TabVIP:CreateButton({
    Name     = T("b_vip"),
    Callback = function()
        local removed, n = RemoveVIPWalls()
        if removed then
            Notify(T("n_vip_t"), T("n_vip_b") .. " (" .. n .. "x)")
        else
            Notify(T("n_vip_t"), T("n_vnone"), 4, 4483347087)
        end
    end,
})

TabVIP:CreateLabel(T("l_vipstat") .. (S.VIPDone and T("l_vip_off") or T("l_vip_on")))

--==============================================================================
-- [17] TAB: AUTO BRAINROT
--==============================================================================

local TabAuto = Win:CreateTab(T("t_auto"), "zap")

TabAuto:CreateSection(T("s_scan"))
TabAuto:CreateLabel(T("i_scan"))

TabAuto:CreateDropdown({
    Name            = T("d_rarity"),
    Options         = RARITIES,
    CurrentOption   = { "Common" },
    MultipleOptions = false,
    Flag            = "RarityPick",
    Callback        = function(v)
        S.Rarity = type(v) == "table" and (v[1] or "Common") or tostring(v)
    end,
})

TabAuto:CreateButton({
    Name     = T("b_search"),
    Callback = function()
        local found, count = SearchBrainrots(S.Rarity)
        if found then
            Notify(T("n_fnd_t"), T("n_fnd_b") .. S.Rarity .. "  (" .. count .. " objects)")
        else
            Notify(T("n_nfnd_t"), T("n_nfnd_b"), 5, 4483347087)
        end
    end,
})

TabAuto:CreateLabel(T("l_hint"))
TabAuto:CreateLabel(T("l_srcount") .. tostring(S.Searches))

TabAuto:CreateDivider()

TabAuto:CreateSection(T("s_tp"))

TabAuto:CreateButton({
    Name     = T("b_tp"),
    Callback = function()
        if #S.Found == 0 then
            Notify("No Cache", "Run a Search first.", 3, 4483347087)
            return
        end
        local ok, name = TeleportToRandom()
        if ok then
            Notify(T("n_tp_t"), T("n_tp_b") .. S.Rarity .. (name and ("  →  " .. name) or ""))
        else
            Notify("Teleport Failed", T("n_tpf"), 4, 4483347087)
        end
    end,
})

TabAuto:CreateLabel(T("l_tpcount") .. tostring(S.Teleports))

TabAuto:CreateDivider()

TabAuto:CreateSection(T("s_esp"))

TabAuto:CreateToggle({
    Name         = T("tog_labels"),
    CurrentValue = true,
    Flag         = "ESPLabels",
    Callback     = function(v)
        S.ESPLabels = v
        if #S.Found > 0 then
            ApplyESP(S.Found, S.Rarity)
        end
    end,
})

TabAuto:CreateButton({
    Name     = T("b_espref"),
    Callback = function()
        if #S.Found == 0 then
            Notify("Nothing to Refresh", "Run a Search first.", 3, 4483347087)
            return
        end
        ApplyESP(S.Found, S.Rarity)
        Notify(T("n_er_t"), T("n_er_b") .. #S.Found .. " objects.")
    end,
})

TabAuto:CreateButton({
    Name     = T("b_espclear"),
    Callback = function()
        ClearESP()
        S.Found = {}
        Notify(T("n_ec_t"), T("n_ec_b"))
    end,
})

--==============================================================================
-- [18] TAB: TELEPORT BASE  (NEW)
--==============================================================================

local TabBase = Win:CreateTab(T("t_base"), "map-pin")

TabBase:CreateSection(T("s_base"))
TabBase:CreateLabel(T("i_base"))
TabBase:CreateLabel(T("i_base2"))

TabBase:CreateButton({
    Name     = T("b_base"),
    Callback = function()
        local ok, name = TeleportToBase()
        if ok then
            Notify(T("n_base_t"), T("n_base_b") .. (name or "Ground"), 4)
        else
            Notify(T("n_base_t"), T("n_basef"), 5, 4483347087)
        end
    end,
})

--==============================================================================
-- [19] TAB: SPEED
-- Toggle enables the 0.2s enforcement loop.
-- Slider sets the target WalkSpeed (16 = default, up to 500).
-- The loop re-applies every tick so game resets have no effect.
--==============================================================================

local TabSpeed = Win:CreateTab(T("t_speed"), "wind")

TabSpeed:CreateSection(T("s_speed"))
TabSpeed:CreateLabel(T("i_speed"))

-- Toggle — master on/off for the speed loop
TabSpeed:CreateToggle({
    Name         = T("tog_speed"),
    CurrentValue = false,
    Flag         = "SpeedToggle",
    Callback     = function(v)
        if v then
            StartSpeedLoop()
            Notify(T("n_spon_t"), T("n_spon_b") .. "  (" .. S.SpeedValue .. " WS)")
        else
            StopSpeedLoop()
            Notify(T("n_spoff_t"), T("n_spoff_b"), 4, 4483347087)
        end
    end,
})

TabSpeed:CreateDivider()

-- Slider — choose WalkSpeed value (16 is Roblox default)
TabSpeed:CreateSlider({
    Name         = T("sl_speed"),
    Range        = { 16, 500 },
    Increment    = 1,
    Suffix       = " WS",
    CurrentValue = 24,
    Flag         = "SpeedSlider",
    Callback     = function(v)
        S.SpeedValue = v
        -- If the loop is already running, it will pick up the new value
        -- on its next 0.2s tick automatically.
        -- For instant feedback, also apply right now:
        if S.SpeedActive then
            ApplySpeed(S.SpeedValue)
        end
    end,
})

TabSpeed:CreateLabel(T("l_spd_cur") .. tostring(S.SpeedValue))

TabSpeed:CreateDivider()

-- Reset button — stops loop and goes back to 16
TabSpeed:CreateButton({
    Name     = T("b_spd_def"),
    Callback = function()
        S.SpeedValue  = 16
        S.SpeedActive = false
        S.SpeedThread = nil
        ResetSpeed()
        Notify(T("n_sprst_t"), T("n_sprst_b"))
    end,
})

--==============================================================================
-- [20] TAB: CREDITS
--==============================================================================

local TabCred = Win:CreateTab(T("t_credits"), "info")

TabCred:CreateSection(T("s_cred"))
TabCred:CreateLabel(T("l_author")  .. ":   " .. META.AUTHOR)
TabCred:CreateLabel(T("l_version") .. ":   " .. META.VERSION)
TabCred:CreateLabel(T("l_game")    .. ":   " .. META.GAME)
TabCred:CreateLabel(T("l_fw")      .. ":   " .. T("l_fw_val"))
TabCred:CreateDivider()

TabCred:CreateSection(T("s_feat"))
TabCred:CreateLabel(T("f1"))
TabCred:CreateLabel(T("f2"))
TabCred:CreateLabel(T("f3"))
TabCred:CreateLabel(T("f4"))
TabCred:CreateLabel("SPEED — 0.2s WalkSpeed enforcement loop (up to 500)")
TabCred:CreateLabel(T("f5"))
TabCred:CreateLabel(T("f6"))
TabCred:CreateDivider()

TabCred:CreateSection(T("s_build"))
TabCred:CreateLabel("Script Brainrot  ·  Build " .. META.VERSION)
TabCred:CreateLabel("Session ID:  " .. math.random(100000, 999999))

--==============================================================================
-- [20] TAB: SETTINGS
-- FIX: Theme now calls Rayfield:SetTheme(rayfieldThemeName) — this is the
-- only correct way to change the Rayfield theme at runtime.
-- FIX: Language dropdown updates S.Lang so T() picks up the new language
-- immediately for all future button callbacks and notifications.
--==============================================================================

local TabSettings = Win:CreateTab(T("t_settings"), "settings")

TabSettings:CreateSection(T("s_lang"))
TabSettings:CreateLabel(T("i_lang"))

TabSettings:CreateDropdown({
    Name            = T("d_lang"),
    Options         = { "English", "Portuguese", "Spanish" },
    CurrentOption   = { "English" },
    MultipleOptions = false,
    Flag            = "LangPick",
    Callback        = function(v)
        local lang = type(v) == "table" and (v[1] or "English") or tostring(v)
        if LANG[lang] then
            S.Lang = lang
            -- Notification uses the NEW language immediately
            Notify(T("n_lang_t"), T("n_lang_b"))
        end
    end,
})

TabSettings:CreateDivider()

TabSettings:CreateSection(T("s_theme"))
TabSettings:CreateLabel(T("i_theme"))

TabSettings:CreateDropdown({
    Name            = T("d_theme"),
    Options         = THEME_KEYS,
    CurrentOption   = { "Black  (Default)" },
    MultipleOptions = false,
    Flag            = "ThemePick",
    Callback        = function(v)
        local pick      = type(v) == "table" and (v[1] or "Black  (Default)") or tostring(v)
        local rfTheme   = THEME_MAP[pick] or "Default"
        S.Theme         = pick

        -- *** THE ACTUAL FIX: call Rayfield's SetTheme method ***
        Safe(function()
            Rayfield:SetTheme(rfTheme)
        end)

        Notify(T("n_thm_t"), T("n_thm_b") .. "  [" .. rfTheme .. "]")
    end,
})

TabSettings:CreateDivider()

TabSettings:CreateSection(T("s_misc"))

TabSettings:CreateButton({
    Name     = T("b_reset"),
    Callback = function()
        S.WavesTotal  = 0
        S.KicksTotal  = 0
        S.Teleports   = 0
        S.Searches    = 0
        Notify(T("n_rst_t"), T("n_rst_b"))
    end,
})

--==============================================================================
-- [21] CLEANUP
-- FIX: BindToClose is SERVER-ONLY — removed entirely.
-- Use LocalPlayer.AncestryChanged instead, which fires client-side.
--==============================================================================

LP.AncestryChanged:Connect(function(_, parent)
    if parent == nil then
        StopWaveLoop()
        StopAutoKick()
        StopSpeedLoop()
        ClearESP()
    end
end)

--==============================================================================
-- [22] STARTUP
-- Lightweight: one initial wave sweep + welcome notification only.
--==============================================================================

task.spawn(function()
    task.wait(1.5)
    Safe(SweepWaves)  -- silent one-shot on load
    Notify(
        T("n_load_t"),
        T("n_load_b") .. LP.DisplayName .. "!",
        6,
        META.IMAGE
    )
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- Script Brainrot  ·  by ByteBandit_Ofici  ·  v3.0.0
-- ═══════════════════════════════════════════════════════════════════════════
