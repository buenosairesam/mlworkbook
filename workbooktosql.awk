BEGIN {
    FS = ";"
    IGNORECASE = 1
    currentlevel = ""
    
    #user for dragndrop
    dndcount = 1
    
    #used for fbm
    last = 0
    #this clears the array
    split("", extitle)
    
    print "SET @currworkbook := LAST_INSERT_ID();"

	while (getline < exercises)
    {
        if ($1 != "")
        {
            
            #print currentlevel
            
            if ($1 ~ /Class/)
            {
                currentlevel = "class"
            }
            else if (currentlevel == "class")
            {
                print "INSERT INTO ilc_workbook_chapter ( chapter_title, workbook_id, active, created_at, updated_at) VALUES ( \""$1"\", @currworkbook, 1, NOW(), NOW());"
                print "SET @currchap := LAST_INSERT_ID();"
                currentlevel = "chapter"
            }
            else if (currentlevel == "chapter" || $1 ~ /-/ ) 
            {
                split($1, extitle, " - ")
                print "INSERT INTO ilc_workbook_chapter_exercise ( exercise_title, directions, active, chapter_id, created_at, updated_at) VALUES ( \""extitle[1]"\",\"" extitle[2] "\", 1, @currchap, NOW(), NOW());"
                print "SET @currex := LAST_INSERT_ID();"
                currentlevel = "exercise"
            }
            else if (currentlevel == "exercise")
            {

                switch ($1)
                {
                    case "DND":
                        enun = $2
                        
                        print "INSERT INTO ilc_workbook_chapter_exercise_item (exercise_type, text, exercise_id, created_at, updated_at) VALUES ( 4, \""enun "\", @currex, NOW(), NOW() );"
                        print "SET @curritem := LAST_INSERT_ID();"
                        wnum = split(enun, words, "/")
                        
                        gsub(/ $/, "", words[1])
                        gsub(/^ /, "", words[1])    
                        gsub(/ $/, "", words[2])
                        gsub(/^ /, "", words[2])
                        
                        print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem," dndcount ",\"" words[1] "\", 1);"
                        print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem," dndcount ",\"" words[2] "\", 1);"
                        dndcount ++
                        currentlevel == "dndstart";
                        break
                        
                    #tercero
                    case "SO":
                        enun = $2
                        answer = $3
                        gsub(/[*+]/, "", answer)

                        punct = ""
                        punctans = ""


                        if ( enun ~ /?/)
                        {
                            punctans = "?"
                        }
                        else if ( enun ~ /\./)
                        {
                            punctans = "."
                        }

                        gsub(/[.?].*/, "", enun)

                        if ( enun ~ /?/)
                        {
                            punct = "?"
                        }
                        else if ( enun ~ /\./)
                        {
                            punct = "."
                        }                        

                        gsub(/[*+]/, "", answer)
                        gsub(answer, "", enun)
                        gsub(/ $/, "", answer)
                        gsub(/^ /, "", answer) 


                        print "INSERT INTO ilc_workbook_chapter_exercise_item (exercise_type, text, exercise_id, created_at, updated_at) VALUES ( 4, \""answer " " punct "\", @currex, NOW(), NOW() );"
                        print "SET @curritem := LAST_INSERT_ID();"
                        
                        print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem,\"\",\"" answer " " punctans "\", 1);"
                        break

                    #segundo
                    case "SC":
                        enun = $2
                        answer = $3

                        punct = ""
                        punctans = ""

                        gsub(/[*+]/, "", answer)
                        gsub(answer, "", enun)
                        gsub(/ $/, "", answer)
                        gsub(/^ /, "", answer) 
                        

                        if ( enun ~ /?/)
                        {
                            punctans = "?"
                        }
                        else if ( enun ~ /\./)
                        {
                            punctans = "."
                        }

                        gsub(/[.?].*/, "", enun)

                        if ( enun ~ /?/)
                        {
                            punct = "?"
                        }
                        else if ( enun ~ /\./)
                        {
                            punct = "."
                        }                        



                        print "INSERT INTO ilc_workbook_chapter_exercise_item (exercise_type, text, exercise_id, created_at, updated_at) VALUES ( 3, \""enun " " punct "\", @currex, NOW(), NOW() );"
                        print "SET @curritem := LAST_INSERT_ID();"
                        
                        print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem,\"\",\"" answer " " punctans "\", 1);"
                        break
                    
                    #primero
                    case "ST":
                        enun = $2
                        num = split($3, answers, ",")

                        punct = ""
                        punctans = ""


                        gsub(/[*+]/, "", answers[1])

                        gsub(answers[1], "", enun)

                        gsub(/ $/, "", answers[1])
                        gsub(/^ /, "", answers[1])
                                           


                        if ( enun ~ /?/)
                        {
                            punctans = "?"
                        }
                        else if ( enun ~ /\./)
                        {
                            punctans = "."
                        }

                        gsub(/[.?].*/, "", enun)
                        

                        if ( enun ~ /?/)
                        {
                            punct = "?"
                        }
                        else if ( enun ~ /\./)
                        {
                            punct = "."
                        }            

                        gsub(/[.?].*/, "", enun)

                        print "INSERT INTO ilc_workbook_chapter_exercise_item (exercise_type, text, exercise_id, created_at, updated_at) VALUES ( 2, \""enun " " punct "\", @currex, NOW(), NOW() );"
                        print "SET @curritem := LAST_INSERT_ID();"


                        for ( i = 1; i < num+1   ; i ++)
                        {
                            gsub(/ $/, "", answers[i])
                            gsub(/^ /, "", answers[i])                        
                            gsub(/[*+]/, "", answers[i])
                            print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem,\"\",\"" answers[i] " " punctans "\", 1);"
                        }


                        break
                    
                    case "FB":
                    case "FBM":
                        last = 0
                        enun = $2

                        #hcnt = 1
                        print "INSERT INTO ilc_workbook_chapter_exercise_item (exercise_type, text, exercise_id, created_at, updated_at) VALUES ( 1, \""enun "\", @currex, NOW(), NOW() );"
                        print "SET @curritem := LAST_INSERT_ID();"
                        
                        wnum = split(enun, words, " ")
                        num = split($3, answers, ",")
                        
                       
                        for ( i = 1; i < num +1  ; i ++)
                        {
 
                            #~ if (i in hints)
                            #~ {
                                #~ thahint = hints[i]
                            #~ }
                            #~ else
                            #~ {
                                #~ thahint = ""
                            #~ }
                            
                            gsub(/[*]/, "", answers[i])
                            gsub(/ $/, "", answers[i])
                            gsub(/^ /, "", answers[i])
                            
                           
                            pos = substr(answers[i], 1, 1)
                            if (pos ~ /[0-9]/)
                            {
                                gsub(pos, "", answers[i])
                                occur = 1
                                
                                for (j = 1; j < wnum + 1; j ++)
                                {
                                    if (answers[i] == words[j])
                                    {
                                        if (ocurr == pos) {
                                            print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem," j - 1 ",\"" answers[i] "\", 1);"
                                            last = j ;
                                            ocurr++
                                        }
                                    }
                                }
                            }
                            else if (pos ~ /[+]/ )
                            {
                                gsub(/[+]/, "", answers[i])
                                print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem," last ",\"" answers[i] "\", 1);"                                
                            }
                            else 
                            {
                                for (j = 1; j < wnum + 1; j ++)
                                {
                                    #print answers[i] 
                                    #print words[j]
                                    
                                    if (answers[i] == words[j])
                                    {
                                        last = j - 1
                                        print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem," j - 1 ",\"" answers[i] "\", 1);"
                                    }
                                }
                            }
                        }
                        break;
                    
                    case "BIN":
                    case "MC":
                        print "INSERT INTO ilc_workbook_chapter_exercise_item (exercise_type, text, exercise_id, created_at, updated_at) VALUES ( 0, \""$2 "\", @currex, NOW(), NOW() );"
                        print "SET @curritem := LAST_INSERT_ID();"
                        num = split($3, answers, ",")
                        for ( i = 1; i < num + 1 ; i ++)
                        {
                            gsub(/ $/, "", answers[i])
                            gsub(/^ /, "", answers[i])
                            if (index(answers[i], "*") != 0) {
                                
                                enun = $2
                                wnum = split(enun, words, " ")                                
                                gsub(/[*+]/, "", answers[i])
                                
                                printitq = 1
                                for ( j = 0; j < wnum  ; j ++)
                                {
                                    if (words[j] == answers[i]) {
                                        print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem," j - 1 ",\"" answers[i] "\", 1);"
                                        printitq = 0
                                    }
                                }
                                if (printitq == 1)
                                {
                                    print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem,NULL,\"" answers[i] "\", 1);"
                                }
                                
                            }
                            else
                                print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem,NULL,\"" answers[i] "\", 0);"
                        }
                        break
                    case "QA":
                        enun = $2
                        
                        num = split($3, answers, ",")
                        gsub(/*/, "", answers[1])
                        gsub(/ $/, "", answers[1])
                        gsub(/^ /, "", answers[1])

                        gsub(answers[1], "", enun)


                        gsub(/[.].*/, "", enun) 
                        gsub(/^[ \t]+|[ \t]+$/,"", enun)


                        print "INSERT INTO ilc_workbook_chapter_exercise_item (exercise_type, text, exercise_id, created_at, updated_at) VALUES ( 10, \"" enun "\", @currex, NOW(), NOW() );"
                        print "SET @curritem := LAST_INSERT_ID();"

                        for ( i = 1; i < num+1   ; i ++)
                        {
                            gsub(/ $/, "", answers[i])
                            gsub(/^ /, "", answers[i])                        
                            gsub(/[+]/, "", answers[i])
                            print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem,NULL,\"" answers[i] "\", 1);"
                        }


                        break

                    default:
                        break
                }
            }
            else if (currentlevel == "dndstart")
            {
                if($1 ~ /DND/)
                {
                    enun = $2
                    
                    print "INSERT INTO ilc_workbook_chapter_exercise_item (exercise_type, text, exercise_id, created_at, updated_at) VALUES ( 4, \""enun "\", @currex, NOW(), NOW() );"
                    print "SET @curritem := LAST_INSERT_ID();"
                    wnum = split(enun, words, "/")
                    
                    gsub(/ $/, "", words[1])
                    gsub(/^ /, "", words[1])
                    gsub(/ $/, "", words[2])
                    gsub(/^ /, "", words[2])
                    
                    print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem," dndcount ",\"" words[1] "\", 1);"
                    print "INSERT INTO ilc_workbook_chapter_exercise_item_answer ( item_id, word_index, text, is_correct_answer) VALUES (@curritem," dndcount ",\"" words[2] "\", 1);"
                    dndcount ++
                }
                else
                {
                    dndcount = 1
                    currentlevel = ""
                }
            }
        }
    }
    
    close(exercises)

}
