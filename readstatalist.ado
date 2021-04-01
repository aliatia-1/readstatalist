program define readstatalist
	syntax [anything] [,UNanswered POst]
	if "`anything'" == ""{
	    local anything 5
	}
	quietly{
		clear
		preserve
		set obs 1
		gen url1 = fileread("https://www.statalist.org/forums/forum/general-stata-discussion/general")
		egen url2 = ends(url1),p(`"tbody class="topic-list ">"') tail trim
		egen url = ends(url2),p(`"<div class="js-pagenav pagenav h-right">"') head
		split url,parse(`"a href=""') generate(uurl)
		split url,parse(`"" class="topic-title js-topic-title">"') generate(ssubject)
		split url,parse(`"<div class="posts-count">"') generate(ppost)
		drop url*
		foreach url of varlist uurl* ppost* ssubject*{
			if substr("`url'",1,3)=="uur" & (strpos(`url',"https://www.statalist.org/forums/forum/general-stata-discussion/general/")==0 | strpos(`url',"?p=")!=0){
				drop `url'
			}
			else if substr("`url'",1,3)=="uur"{
				egen `=substr("`url'",2,strlen("`url'"))' = ends(`url'),p(`"""') head
			}
			else{
				egen `=substr("`url'",2,strlen("`url'"))' = ends(`url'),p("<") head
			}
		}
		drop subject1 post1 uurl* ppost* ssubject*
		foreach i in "url" "post" "subject"{
			rename `i'# `i'#, renumber sort
		}
		gen i = _n
		reshape long url subject post, i(i) j(j)
		destring post,force replace
		replace post = post-1
		if "`post'" != ""{
			forval i = 1/`=`anything''{
				if "`unanswered'" != ""{
					drop if post!=0
					gen x1 = fileread("`=url[`i']'") in 1
					egen x2 = ends(x1), p(`"itemprop="text">"') tail
					egen x = ends(x2), p(`"<!-- REPLY -->"') head
					replace x = ustrregexra(x,"<.*?>","")
					replace x = ustrtrim(x)
					noisily di `"`i': {browse "`=url[`i']'":`=subject[`i']'}"' 
					noisily di x[1]
					noisily di ""
					drop x1 x2 x
				}
				else{
					gen x1 = fileread("`=url[`i']'") in 1
					egen x2 = ends(x1), p(`"itemprop="text">"') tail
					egen x = ends(x2), p(`"<!-- REPLY -->"') head
					replace x = ustrregexra(x,"<.*?>","")
					replace x = ustrtrim(x)
					noisily di `"`i': {browse "`=url[`i']'":`=subject[`i']'}"' 
					noisily di "Replies: `=post[`i']'"
					noisily di x[1]
					noisily di ""
					drop x1 x2 x
				}
			}
		}
		else{
			forval i = 1/`=`anything''{
				if "`unanswered'" != ""{ 
					drop if post!=0
					noisily di `"`i': {browse "`=url[`i']'":`=subject[`i']'}"' 
					noisily di ""
				}
				else{
					noisily di `"`i': {browse "`=url[`i']'":`=subject[`i']'}"' 
					noisily di "Replies: `=post[`i']'"
					noisily di ""
				}
			}
		}
	}
end
