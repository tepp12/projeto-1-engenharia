class_name Cat
extends RefCounted

enum Status {
	ATIVO,
	INATIVO
} 

const NOME_MAX_CARACTERES := 20

var cat_id: String
var cat_type: String # checar se deve ser String ou outro tipo
var name: String:
	set(value):
		if value.length() > NOME_MAX_CARACTERES:
			push_error("Nome excede o limite de %d caracteres" % NOME_MAX_CARACTERES)
			return
		if value.strip_edges() == "":
			push_error("Nome não pode ser vazio")
			return
		name = value
var status: Status #enum definido em Ativo ou Descartado 



func _init(id: String, type: String, cat_name: String):
	cat_id = id
	cat_type = type
	name = cat_name
	status = Status.ATIVO

func to_dict() -> Dictionary:
	return {
		"id": cat_id,
		"type": cat_type,
		"name": name,
		"status": Status.keys()[status]  # converte enum -> string legível, ex: "ATIVO"
	}
	
static func from_dict(data: Dictionary) -> Cat:
	if not data.has("id") or not data.has("type") or not data.has("name") or not data.has("status"):
		push_error("Dados de gato incompletos: " + str(data))
		return null

	var status_str: String = data["status"]
	if not Status.keys().has(status_str):
		push_error("Status desconhecido: " + status_str)
		return null

	var cat := Cat.new(data["id"], data["type"], data["name"])
	cat.status = Status[status_str]
	return cat

func _to_string() -> String:
	return "Cat: {id=%s, type=%s, name=%s, status=%s}" % [cat_id, cat_type, name, status]
