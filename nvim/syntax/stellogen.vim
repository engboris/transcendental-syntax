syn clear

syn keyword sgKeyword show exec trace process end galaxy run interface
syn match sgComment "\s*'[^'].*$"
syn region sgComment start="'''" end="'''" contains=NONE
syn region sgString start=/\v"/ skip=/\v\\./ end=/\v"/
syn match sgSeparator "[;\.\{\}\:\[\]|]"
syn match sgOperator "[=@]"
syn match sgOperator "=>"
syn match sgOperator "!="

hi link sgKeyword Keyword
hi link sgComment Comment
hi link sgOperator Operator
hi link sgSeparator Special
hi link sgString String
