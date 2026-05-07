## Boss wave modifiers — applied during boss waves (4, 8, 12).
class_name BossModifier

enum Type {
	NONE,
	RUEE,     # Enemies move 50% faster
	FAMINE,   # Gold rewards reduced by 40%
	MARCHE,   # 2× enemy count per group
	CUIRASSE, # All enemies gain flat armor +5
	ESSAIM,   # All enemies are swarm type (spawn 3 units on death)
}

static func label(t: Type) -> String:
	match t:
		Type.RUEE:     return "Ruée — ennemis 50% plus rapides"
		Type.FAMINE:   return "Famine — or réduit de 40%"
		Type.MARCHE:   return "Grande Marche — 2× ennemis"
		Type.CUIRASSE: return "Cuirassés — +5 armure"
		Type.ESSAIM:   return "Essaim — chaque ennemi se divise à la mort"
		_:             return ""
