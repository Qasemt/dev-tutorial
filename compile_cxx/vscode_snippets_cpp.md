### Snippets file for VSCODES (C++)
name : cpp.json 

_______
``` json
{

		"macro1": {
		"prefix": "defmsvc",
		"body": [
			"#if defined(_MSC_VER)\n#endif",
			"$2"
		],
		"description": "macro msvc"
	}
	,	"macro2": {
		"prefix": "defmsvc_else",
		"body": [
			"#if defined(_MSC_VER)\n#else\n#endif",
			"$2"
		],
		"description": "macro msvc else"
	}
	,	"macro3": {
		"prefix": "defGNUC_else",
		"body": [
			"#if defined(__GNUC__)\n#else\n#endif",
			"$2"
		],
		"description": "macro GNU else"
	}
	,	"macro4": {
		"prefix": "defMSVC_GNU",
		"body": [
			"#if defined(_MSC_VER)\n#elif defined(__GNUC__)\n#endif",
			"$2"
		],
		"description": "macro GNU _MSC_VER"
	}
}

```
