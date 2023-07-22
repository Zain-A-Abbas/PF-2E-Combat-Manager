extends Node

var senses_tooltips_list: Array[String] = [
	"darkvision",
	"scent",
]

# [Name|] at the start is for the header in the tooltip menu
var senses_tooltips := {
	"darkvision": "Darkvision|A monster with darkvision can see perfectly well in areas of darkness and dim light, though such vision is in black and white only. Some forms of magical darkness, such as a 4th-level darkness spell, block normal darkvision. A monster with greater darkvision, however, can see through even these forms of magical darkness.",
	"scent": "Scent|Scent involves sensing creatures or objects by smell, and is usually a vague sense. The range is listed in the ability, and it functions only if the creature or object being detected emits an aroma (for instance, incorporeal creatures usually do not exude an aroma).\n\nIf a creature emits a heavy aroma or is upwind, the GM can double or even triple the range of scent abilities used to detect that creature, and the GM can reduce the range if a creature is downwind. "
}
