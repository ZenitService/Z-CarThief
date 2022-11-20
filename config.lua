Config = {}

Config.DisattivaDialoghi = false -- true o false - mettere in true se si vuole saltare la storia e tutti i dialoghi

Config.WebHook = 'https://discord.com/webhooks' -- Link WebHook Discord
Config.ColoreEmbed = '16777215' -- Colore Embed Discord

Config.TipoPagamento = 'black_money' -- black_money - money - bank (Soldi Sporchi - Contanti - In Banca)
Config.Paga = 25000 -- Ricompensa dopo aver completato il furto d'auto
Config.MinutiDiCooldown = 10 -- Minuti Di Cooldown Dopo i quali Si può Startare un altro furto D'auto

Config.NomeJobPol = 'police' -- Nome Job Della Polizia
Config.MinPolizia = 0 -- Minimo Di Poliziotti Online Per Startare Il Furto D'auto
Config.StartPosizione = 25000 --Tempo in millisecondi dopo il quale la polizia saprà la posizione del rapinatore in auto
Config.RefreshPosizione = 6000 -- Refresh in millisecondi della posizione del rapinatore in auto alla polizia

Config.DestinazioniAuto = { -- Destinazioni e Auto Rubate Casuali

	Destinazione1 = {
		Coordinate   = vector3(3585.97,3758.99,29.92),
		Auto = {'alpha','ardent','banshee','banshee2'},
	},
	Destinazione2 = {
		Coordinate   = vector3(1493.68,3579.42,35.22),
		Auto = {'cheetah','comet2','elegy2','comet5'},
	},
	Destinazione3 = {
		Coordinate   = vector3(1547.65,6478.04,22.81),
		Auto = {'alpha','ardent','banshee','banshee2'},
	},
	Destinazione4 = {
		Coordinate   = vector3(-2194.73,4268.01,48.55),
		Auto = {'cheetah','comet2','elegy2','comet5'},
	},
}