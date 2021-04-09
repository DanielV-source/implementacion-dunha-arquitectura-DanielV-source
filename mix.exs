########################################################################
##
##                        SIMPLE USER LOGIN APP
##
##  Author: Daniel Vicente Ramos
##
########################################################################

import Kernel
defmodule Client do

    @doc """
        Client trying to sign up in app
    """
    def signup(username, email, pass) do
        msg("Request petition of signup to App")
        App.signup(username, email, pass)
    end

    @doc """
        Client trying to login in app
    """
    def login(useremail, pass) do
        msg("Request petition of login to App")
        App.login(useremail, pass)
    end

    @doc """
        Client trying to get information of his/her profile in app
    """
    def getInfo() do
        msg("Request petition of get info to App")
        App.getInfo()
    end

    @doc """
        Client trying to get information of user profile in app (Public, no privileges required)
    """
    def getInfo(useremail) do
        msg("Request petition of get user info to App")
        App.getInfo(useremail)
    end

    @doc """
        Client trying to change info in app
    """
    def changeInfo(n, ln, pn) do
        msg("Request petition of change info to App")
        App.changeInfo(n, ln, pn)
    end

    @doc """
        Client trying to change user info in app (Privileges required)
    """
    def changeInfo(useremail, n, ln, pn) do
        msg("Request petition of change user info to App")
        App.changeInfo(useremail, n, ln, pn)
    end

    @doc """
        Client trying to change pass in app
    """
    def changePass(np) do
        msg("Request petition of change pass to App")
        App.changePass(np)
    end

    @doc """
        Client trying to change user pass in app (Privileges required)
    """
    def changePass(useremail, np) do
        msg("Request petition of change user pass to App")
        App.changePass(useremail, np)
    end

    @doc """
        Client trying to sign out in app
    """
    def signout() do
        msg("Request petition of sign out to App")
        App.signout()
    end

    @doc """
        Client trying to remove his/her user account in app
    """
    def remAccount() do
        msg("Request petition of remove user account to App")
        App.remAccount()
    end

    @doc """
        Client trying to remove an user account in app (Privileges required)
    """
    def remAccount(useremail) do
        msg("Request petition of remove user account to App")
        App.remAccount(useremail)
    end

    defp msg(text) do
        IO.puts "CLIENT: #{text}"
    end
end

defmodule App do
    defp _APP_ACCESS, do: "app" #For Database queries

    ########################################################################
    ##
    ##                             SIGN UP
    ##
    ########################################################################

    @doc """
        Sign up in App
    """
    def signup(username, email, pass) do
        if (username == nil || email == nil || pass == nil) do
            checkErrors(:error_input_data_empty)
            :error_input_data_empty
        else 
            msg("Looking if parameters are valid")
            lu = String.length(username)
            domain = String.split(email, ["@", ".com", ".es", ".org", ".net"])
            lp = String.length(pass)
            if(checkIfParametersAreValid(lu, domain, lp) == true) do
                msg("Looking if username or email was used")
                check = checkIfUserWasTaken(username, email)
                if (check == :ok) do
                    msg("Completing registration...")
                    cuser = Database.insert([username, email, pass], _APP_ACCESS(), "Users")
                    if(cuser == :ok) do
                        msg("Success registration!")
                        :ok
                    else 
                        if(cuser == :error_no_admin) do
                            checkErrors(:error_no_admin)
                            :error_no_admin
                        else
                            checkErrors(:error_db)
                            :error_db
                        end
                    end
                else 
                    if (check == :error_db) do
                        checkErrors(:error_db)
                        :error_db
                    else
                        :error
                    end
                end
            else 
                :error
            end
        end   
    end

    defp checkIfParametersAreValid(lu, domain, lp) do
        if (lu < 4 || lu > 15) do
            checkErrors(:error_user_length)
            :error_user_length
        else
            if (checkIfEmailIsValid(domain) == false) do
                checkErrors(:error_email)
                :error_email
            else
                if (lp < 4 || lp > 15) do
                    checkErrors(:error_pass_length)
                    :error_pass_length
                else
                    true
                end
            end
        end
    end

    defp checkIfEmailIsValid([]) do
        false
    end
    defp checkIfEmailIsValid([h|t]) do
        if (h != "" && t != [] && t != "") do
            true
        else 
            false
        end
    end

    defp checkIfUserWasTaken(t, t1) do
        u = Database.select(t, "Users")
        e = Database.select(t1, "Users")
        if (u == :error_user_not_found && e == :error_user_not_found) do
            :ok
        else 
            if (u == :error_db || e == :error_db) do
                checkErrors(:error_db)
                :error_db
            else 
                if(u == :error_no_db || e == :error_no_db) do
                    :ok
                else
                    checkErrors(:error_user_taken)
                    :error_user_taken
                end
            end
        end 
    end

    ########################################################################
    ##
    ##                             LOGIN
    ##
    ########################################################################

    @doc """
        Login user in App
    """
    def login(useremail, pass) do
        msg("Checking if username/email and password match...")
        session = Database.selectAllContent("Session")
        found = Database.selectOrAnd([useremail, pass], "Users")
        if (found != [] && found != :error_user_not_found 
                && (session == [""] || session == :error_no_db) && session != :error_db) do
            #Create session
            csession = Database.insert([useremail], _APP_ACCESS(), "Session")
            if(csession == :ok) do
                msg("Login successful!")
                msg("Welcome again, #{useremail}!")
                :ok
            else
                if(csession == :error_no_admin) do
                    checkErrors(:error_no_admin)
                    :error_no_admin
                else
                    checkErrors(:error_db)
                    :error_db
                end
            end
        else 
            if(session == :error_db) do
                checkErrors(:error_db)
                :error_db
            else
                if(found == :error_user_not_found) do
                    checkErrors(:error_login)
                    :error_login
                else
                    checkErrors(:error_session_exists)
                    :error_session_exists
                end
            end
        end
    end

    ########################################################################
    ##
    ##                             INFO
    ##
    ########################################################################

    @doc """
        Get info from current user 
    """
    def getInfo() do
        session = Database.selectAllContent("Session")
        if (session != [""] && session != :error_db && session != :error_no_db) do
            msg("Getting user info...")
            l = Database.selectRow(["#{session}"], "Info")
            if(l != :error_no_db && l != :error_db) do
                [h|t] = Database.selectRow(["#{session}"], "Users")
                
                if(l != [""] && l != :error_user_not_found) do
                    [_ | t2] = l  #Username
                    [_ | t3] = t2 #Email
                    [h4 | t4] = t3 #Name
                    [h5 | t5] = t4 #Last Name
                    [h6 | _] = t5 #Phone Number
                    IO.puts " >Username: #{h} \n >Email: #{t} \n >Name: #{h4} \n >Last Name: #{h5} \n >Phone Number: #{h6}"
                    :ok
                else
                    checkErrors(:error_no_data_found)
                    :error_no_data_found #ERROR NO DATA FOUND
                end
            else
                checkErrors(:error_no_data_found)
                :error_no_data_found #ERROR NO DATA FOUND
            end
        else 
            if(session == :error_db) do
                checkErrors(:error_db)
                :error_db
            else
                checkErrors(:error_no_session)
                :error_no_session
            end
        end
    end

    @doc """
        Get info from user in App
    """
    def getInfo(useremail) do
        msg("Getting user info...")
        l = Database.selectRow(["#{useremail}"], "Info")
        if(l != :error_no_db && l != :error_db && l != :error_user_not_found) do
            d = Database.selectRow(["#{useremail}"], "Users")
            if(d != :error_user_not_found) do
                [h|t] = d
                if(h != "") do
                    [_ | t2] = l  #Username
                    [_ | t3] = t2 #Email
                    [h4 | t4] = t3 #Name
                    [h5 | t5] = t4 #Last Name
                    [h6 | _] = t5 #Phone Number
                    IO.puts " >Username: #{h} \n >Email: #{t} \n >Name: #{h4} \n >Last Name: #{h5} \n >Phone Number: #{h6}"
                    :ok
                else
                    checkErrors(:error_no_data_found)
                    :error_no_data_found #ERROR NO DATA FOUND
                end
            else
                checkErrors(:error_user_not_found)
                :error_user_not_found
            end
        else
            checkErrors(:error_no_data_found)
            :error_no_data_found #ERROR NO DATA FOUND
        end
    end

    @doc """
        Change info (name, last name, phone number) and insert to DB
    """
    def changeInfo(n, ln, pn) do
        session = Database.selectAllContent("Session")
        if (session != [""] && session != :error_db && session != :error_no_db) do
            if (n != "" && ln != "" && pn != "") do
                msg("Trying to save changes...")
                [h|t] = Database.selectRow(["#{session}"], "Users")
                l = Database.selectRow(["#{session}"], "Info")
                if(l != [""] && l != :error_user_not_found && l != :error_no_db) do
                    up = Database.update([h, t, n, ln, pn], _APP_ACCESS(), "Info")
                    if(up != :error_no_admin) do
                        msg("All changes saved")
                        :ok
                    else
                        checkErrors(:error_no_admin)
                        :error_no_admin
                    end
                else
                    cinfo = Database.insert([h, t, n, ln, pn], _APP_ACCESS(), "Info")
                    if(cinfo == :ok) do
                        msg("All changes saved")
                        :ok
                    else 
                        if(cinfo == :error_no_admin) do
                            checkErrors(:error_no_admin)
                            :error_no_admin
                        else
                            checkErrors(:error_db)
                            :error_db
                        end
                    end
                end
            else 
                if(session == :error_db) do
                    checkErrors(:error_db)
                    :error_db
                else
                    checkErrors(:error_input_data_empty)
                    :error_input_data_empty
                end
            end
        else
            checkErrors(:error_no_session)
            :error_no_session
        end
    end

    @doc """
        Change info (name, last name, phone number) and insert to DB (only if you have privileges)
    """
    def changeInfo(useremail, n, ln, pn) do
        session = Database.selectAllContent("Session")
        if (session != [""] && session != :error_db && session != :error_no_db) do
            if (n != "" && ln != "" && pn != "") do
                msg("Trying to save changes...")
                [hx|tx] = Database.selectRow(["#{session}"], "Users")
                d = Database.selectRow(["#{useremail}"], "Users")
                if (d != :error_no_db && d != :error_user_not_found) do
                    [h|t] = d
                    if (hx == h || tx == t) do  #If the user is the same, allow to change info
                        l = Database.selectRow(["#{useremail}"], "Info")
                        if(l != [""] && l != :error_user_not_found && l != :error_no_db) do
                            up = Database.update([h, t, n, ln, pn], _APP_ACCESS(), "Info")
                            if(up != :error_no_admin) do
                                msg("All changes saved")
                                :ok
                            else
                                checkErrors(:error_no_admin)
                                :error_no_admin
                            end
                        else
                            cinfo = Database.insert([h, t, n, ln, pn], hx, "Info")
                            if(cinfo == :ok) do
                                msg("All changes saved")
                                :ok
                            else 
                                if(d == :error_user_not_found) do
                                    checkErrors(:error_user_not_found)
                                    :error_user_not_found
                                else
                                    if(cinfo == :error_no_admin) do
                                        checkErrors(:error_no_admin)
                                        :error_no_admin
                                    else
                                        checkErrors(:error_db)
                                        :error_db
                                    end
                                end
                            end
                        end
                    else
                        l = Database.selectRow(["#{useremail}"], "Info")
                        if(l != [""] && l != :error_user_not_found) do
                            up = Database.update([h, t, n, ln, pn], hx, "Info")
                            if(up != :error_no_admin) do
                                msg("All changes saved")
                                :ok
                            else
                                checkErrors(:error_no_admin)
                                :error_no_admin
                            end
                        else
                            cinfo = Database.insert([h, t, n, ln, pn], hx, "Info")
                            if(cinfo == :ok) do
                                msg("All changes saved")
                                :ok
                            else 
                                if(d == :error_user_not_found) do
                                    checkErrors(:error_user_not_found)
                                    :error_user_not_found
                                else
                                    if(cinfo == :error_no_admin) do
                                        checkErrors(:error_no_admin)
                                        :error_no_admin
                                    else
                                        checkErrors(:error_db)
                                        :error_db
                                    end
                                end
                            end
                        end
                    end
                else
                    checkErrors(:error_user_not_found)
                    :error_user_not_found
                end
            else 
                checkErrors(:error_input_data_empty)
                :error_input_data_empty
            end
        else
            checkErrors(:error_no_session)
            :error_no_session
        end
    end


    @doc """
        Change pass (new_pass) of current user
    """
    def changePass(np) do
        session = Database.selectAllContent("Session")
        if (session != [""] && session != :error_db && session != :error_no_db) do
            lnp = String.length(np)
            if (np != "" && lnp >= 4 && lnp <= 15) do
                msg("Trying to save changes...")
                l = Database.selectRow(["#{session}"], "Users")
                if(l != [""] && l != :error_user_not_found && l != :error_no_db) do
                    [h|t] = l
                    up = Database.update([h, t, np], _APP_ACCESS(), "Users")
                    if(up != :error_no_admin) do
                        msg("All changes saved")
                        :ok
                    else
                        checkErrors(:error_no_admin)
                        :error_no_admin
                    end
                else
                    checkErrors(:error_user_not_found)
                    :error_user_not_found
                end
            else 
                if(session == :error_db) do
                    checkErrors(:error_db)
                    :error_db
                else
                    if(lnp < 4 || lnp > 15) do
                        checkErrors(:error_pass_length)
                        :error_pass_length
                    else
                        checkErrors(:error_input_data_empty)
                        :error_input_data_empty
                    end
                end
            end
        else
            checkErrors(:error_no_session)
            :error_no_session
        end
    end

    @doc """
        Change pass (useremail, new_pass) of user (Privileges Required)
    """
    def changePass(useremail, np) do
        session = Database.selectAllContent("Session")
        if (session != [""] && session != :error_db && session != :error_no_db) do
            if (np != "") do
                msg("Trying to save changes...")
                d = Database.selectRow(["#{session}"], "Users")
                d2 = Database.selectRow(["#{useremail}"], "Users")
                if(d2 != [""] && d2 != :error_user_not_found && d2 != :error_no_db) do
                    [h | t] = d2
                    [hx | tx] = d
                    if (hx == h || tx == t) do  #If the user is the same, allow to change info
                        up = Database.update([h, t, np], _APP_ACCESS(), "Users")
                        if(up != :error_no_admin) do
                            msg("All changes saved")
                            :ok
                        else
                            checkErrors(:error_no_admin)
                            :error_no_admin
                        end
                    else
                        up = Database.update([h, t, np], hx, "Users")
                        if(up != :error_no_admin) do
                            msg("All changes saved")
                            :ok
                        else
                            checkErrors(:error_no_admin)
                            :error_no_admin
                        end
                    end
                else
                    :error_user_not_found
                end
            else 
                if(session == :error_db) do
                    checkErrors(:error_db)
                    :error_db
                else
                    checkErrors(:error_input_data_empty)
                    :error_input_data_empty
                end
            end
        else
            checkErrors(:error_no_session)
            :error_no_session
        end
    end

    ########################################################################
    ##
    ##                             Sign out
    ##
    ########################################################################

    def signout() do
        session = Database.selectAllContent("Session")
        if (session != [""] && session != :error_db && session != :error_no_db) do
            msg("Signing out...")
            out = Database.drop(_APP_ACCESS(), "Session")
            if(out != :error_db && out != :error_no_admin) do
                msg("Sign out successfully! Come back soon!")
                :ok
            else 
                if(out == :error_no_admin) do
                    checkErrors(:error_no_admin)
                    :error_no_admin
                else
                    checkErrors(:error_db)
                    :error_db
                end
            end
        else 
            if(session == :error_db) do
                checkErrors(:error_db)
                :error_db
            else
                checkErrors(:error_no_session)
                :error_no_session
            end
        end
    end

    ########################################################################
    ##
    ##                         Remove account
    ##
    ########################################################################

    @doc """
        Remove current user account
    """
    def remAccount() do
        session = Database.selectAllContent("Session")
        if (session != [""] && session != :error_db && session != :error_no_db) do
            d = Database.selectRow(["#{session}"], "Users")
            if (d != :error_no_db && d != :error_user_not_found) do
                [h | _] = d
                #Remove user
                dltuser = Database.delete([h], _APP_ACCESS(), "Users")
                if(dltuser != :error_db && dltuser != :error_no_admin) do
                    #Remove session
                    out = Database.drop(_APP_ACCESS(), "Session")
                    if(out != :error_db && out != :error_no_admin) do
                        msg("Account removed :'(")
                        #Remove info
                        dlt = Database.delete([h], _APP_ACCESS(), "Info")
                        if(dlt != :error_db && dlt != :error_no_admin) do
                           :ok
                        else #No info or error
                            if(dlt == :error_no_admin) do
                                checkErrors(:error_no_admin)
                                :error_no_admin
                            else
                                if(dlt == :error_db) do
                                    checkErrors(:error_db)
                                    :error_db
                                else
                                    :ok
                                end
                            end
                        end
                    else
                        if(:error_no_admin) do
                            checkErrors(:error_no_admin)
                            :error_no_admin
                        else
                            checkErrors(:error_db)
                            :error_db
                        end
                    end
                else
                    if(dltuser == :error_no_admin) do
                        checkErrors(:error_no_admin)
                        :error_no_admin
                    else
                        :error
                    end
                end
            else
                if(d == :error_no_db) do
                    checkErrors(:error_db)
                    :error_db
                else
                    checkErrors(:error_user_not_found)
                    :error_user_not_found
                end
            end
        else
            checkErrors(:error_no_session)
            :error_no_session
        end
    end

     @doc """
        Remove an user account
    """
    def remAccount(useremail) do
        session = Database.selectAllContent("Session")
        if (session != [""] && session != :error_db && session != :error_no_db) do
            d2 = Database.selectRow(["#{useremail}"], "Users")
            d = Database.selectRow(["#{session}"], "Users")
            if (d != :error_no_db && d != :error_user_not_found 
                && d2 != :error_no_db && d2 != :error_user_not_found) do
                [h | _] = d
                [hv | _] = d2
                if(h == hv) do # Remove current account no privileges needed
                    #Remove user
                    dltuser = Database.delete([h], _APP_ACCESS(), "Users")
                    if(dltuser != :error_db && dltuser != :error_no_admin) do
                        msg("Closing current session...")
                        #Remove session
                        out = Database.drop(_APP_ACCESS(), "Session")
                        if(out != :error_db && out != :error_no_admin) do
                            msg("Closed session, removing account...")
                            #Remove info
                            dlt = Database.delete([h], _APP_ACCESS(), "Info")
                            if(dlt != :error_db && dlt != :error_no_admin) do
                                msg("Account and data removed :'(")
                               :ok
                            else #No info or error
                                if(dlt == :error_no_admin) do
                                    checkErrors(:error_no_admin)
                                    :error_no_admin
                                else
                                    if(dlt == :error_db) do
                                        checkErrors(:error_db)
                                        :error_db
                                    else
                                        msg("Account removed :'(")
                                        :ok
                                    end
                                end
                            end
                        else
                            if(:error_no_admin) do
                                checkErrors(:error_no_admin)
                                :error_no_admin
                            else
                                checkErrors(:error_db)
                                :error_db
                            end
                        end
                    else
                        if(dltuser == :error_no_admin) do
                            checkErrors(:error_no_admin)
                            :error_no_admin
                        else
                            :error
                        end
                    end
                else
                    #Remove user
                    dltuser = Database.delete([hv], h, "Users")
                    if(dltuser != :error_db && dltuser != :error_no_admin) do
                        #Remove info
                        dlt = Database.delete([hv], h, "Info")
                        if(dlt != :error_db && dlt != :error_no_admin) do
                            msg("Account and data removed :'(")
                           :ok
                        else #No info or error
                            if(dlt == :error_no_admin) do
                                checkErrors(:error_no_admin)
                                :error_no_admin
                            else
                                if(dlt == :error_db) do
                                    checkErrors(:error_db)
                                    :error_db
                                else
                                    msg("Account removed :'(")
                                    :ok
                                end
                            end
                        end
                    else
                        if(dltuser == :error_no_admin) do
                            checkErrors(:error_no_admin)
                            :error_no_admin
                        else
                            :error
                        end
                    end
                end
            else
                if(d == :error_no_db) do
                    checkErrors(:error_db)
                    :error_db
                else
                    checkErrors(:error_user_not_found)
                    :error_user_not_found
                end
            end
        else
            checkErrors(:error_no_session)
            :error_no_session
        end
    end

    ########################################################################
    ##
    ##                             ERRORS
    ##
    ########################################################################
    defp checkErrors(error) do
        case error do
            :error_user_length -> msg("/!\\ERROR Username, min length 4 and max length 15 characters")
            :error_email -> msg("/!\\ERROR Email is not valid")
            :error_pass_length -> msg("/!\\ERROR Password, min length 4 and max length 15 characters")
            :error_db -> msg("/!\\ERROR Error in database, contact with admin")
            :error_user_taken -> msg("/!\\ERROR Username or email was taken")
            :error_login -> msg("/!\\ERROR Username/email and password don't match with DB")
            :error_no_session -> msg("/!\\ERROR No session found, login is required to do this action")
            :error_session_exists -> msg("/!\\ERROR Session found, sign out current session to login")
            :error_user_not_found -> msg("/!\\ERROR User not found.")
            :error_no_data_found -> msg("/!\\ERROR No user data found, change info in App to retrieve your user data")
            :error_no_admin -> msg("/!\\ERROR You don't have enough privileges to do this action")
            :error_input_data_empty -> msg("/!\\ERROR Input data can't contain null values")
            :error -> msg("/!\\ERROR App not working")
        end
    end
    defp msg(text) do
        IO.puts "SERVER: #{text}"
    end
end

defmodule Database do
    defp _ADMIN_USERS, do: ["root", "app"]
    defp _USERS_DB, do: ["db.txt", 3]
    defp _INFO_DB, do: ["info.txt", 5]
    defp _SESSIONS_DB, do: ["sessions.txt", 1]
    @doc """
        Create DB if it doesn't exists
    """
    def create(user, db) do
        case db do
            "Users" ->  if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do
                            File.write(get(_USERS_DB(), 0), "", [:append])
                            :ok
                        else
                            :error_no_admin
                        end
            "Info" ->   if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do
                            File.write(get(_INFO_DB(), 0), "", [:append])
                            :ok
                        else
                            :error_no_admin
                        end
            "Session" -> File.write(get(_SESSIONS_DB(), 0), "", [:append])
            :ok
        end
    end

    @doc """
        Drop DB if exists
    """
    def drop(user, db) do
        case db do 
            "Users" ->  if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do
                            File.rm_rf(get(_USERS_DB(), 0))
                            :ok
                        else
                            :error_no_admin
                        end
            "Info" ->   if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do
                            File.rm_rf(get(_INFO_DB(), 0))
                            :ok
                        else
                            :error_no_admin
                        end
            "Session" -> File.rm_rf(get(_SESSIONS_DB(), 0))
            _ -> msg("Can't drop DB") 
            :error_db
        end
        :ok
    end

    @doc """
        Save a new registry on DB
    """
    def insert(list, user, db) do
        test = Enum.join(list, "-")
        case db do 
            "Users" ->  if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do
                            File.write(get(_USERS_DB(), 0), test <> "\n", [:append])
                            :ok
                        else
                            :error_no_admin
                        end
            "Info" ->   if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do
                            File.write(get(_INFO_DB(), 0), test <> "\n", [:append])
                            :ok
                        else
                            :error_no_admin
                        end
            "Session" -> if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do
                            File.write(get(_SESSIONS_DB(), 0), test <> "\n", [:append])
                            :ok
                        else
                            :error_no_admin
                        end
        end
    end

    @doc """
        Select a value in DB
    """
    def select(val, db) do
        case db do
            "Users" -> data = getData(get(_USERS_DB(), 0))
            if(data != :error_no_db) do 
                contents = String.split(data, ["\n", "-"])
                result = search(contents, 0, val)       
                result
            else
                :error_no_db
            end
            "Info" -> data = getData(get(_INFO_DB(), 0))
            if(data != :error_no_db) do
                contents = String.split(data, ["\n", "-"])
                result = search(contents, 0, val)       
                result
            else
                :error_no_db
            end
            "Session" -> data = getData(get(_SESSIONS_DB(), 0))
            if(data != :error_no_db) do
                contents = String.split(data, ["\n", "-"])
                result = search(contents, 0, val)       
                result
            else
                :error_no_db
            end
            _ -> msg("Can't select DB") 
            :error_db
        end
    end

    @doc """
        Select a value in DB with OR and AND condition
    """
    def selectOrAnd(val, db) do
        case db do 
            "Users" -> data = getData(get(_USERS_DB(), 0))
            if(data != :error_no_db) do 
                contents = String.split(data, ["\n", "-"])
                result = searchOrAnd(contents, val)       
                result
            else
                :error_no_db
            end
            "Info" -> data = getData(get(_INFO_DB(), 0))
            if(data != :error_no_db) do 
                contents = String.split(data, ["\n", "-"])
                result = searchOrAnd(contents, val)       
                result
            else
                :error_no_db
            end
            "Session" -> data = getData(get(_SESSIONS_DB(), 0))
            if(data != :error_no_db) do
                contents = String.split(data, ["\n", "-"])
                result = searchOrAnd(contents, val)       
                result
            else
                :error_no_db
            end
            _ -> msg("Can't select DB") 
            :error_db
        end
    end

    @doc """
        Select all content in DB
    """
    def selectAllContent(db) do
        case db do 
            "Users" -> data = getData(get(_USERS_DB(), 0))
            if(data != :error_no_db) do
                contents = String.split(data, ["\n", "-"])
                contents
            else
                :error_no_db
            end
            "Info" -> data = getData(get(_INFO_DB(), 0))
            if(data != :error_no_db) do   
                contents = String.split(data, ["\n", "-"])
                contents
            else
                :error_no_db
            end
            "Session" -> data = getData(get(_SESSIONS_DB(), 0))
            if(data != :error_no_db) do
                contents = String.split(data, ["\n", "-"])
                contents
            else
                :error_no_db
            end
            _ -> msg("Can't select DB") 
            :error_db
        end
    end

    @doc """
        Select a row in DB
    """
    def selectRow(val, db) do
        case db do 
            "Users" -> data = getData(get(_USERS_DB(), 0))
            if(data != :error_no_db) do
                contents = String.split(data, ["\n", "-"])
                result = searchRow(contents, val)       
                result
            else
                :error_no_db
            end
            "Info" -> data = getData(get(_INFO_DB(), 0))
            if(data != :error_no_db) do    
                contents = String.split(data, ["\n", "-"])
                result = searchRow(contents, val, get(_INFO_DB(), 1))  
                result
            else
                :error_no_db
            end
            "Session" -> data = getData(get(_SESSIONS_DB(), 0))
            if(data != :error_no_db) do
                contents = String.split(data, ["\n", "-"])
                result = searchRow(contents, val)       
                result
            else
                :error_no_db
            end
            _ -> msg("Can't select DB") 
            :error_db
        end
    end

    @doc """
        Update a row in DB
    """
    def update(values, user, db) do
        case db do 
            "Users" -> data = getData(get(_USERS_DB(), 0))
            if(data != :error_no_db) do
                if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do
                    contents = String.split(data, ["\n", "-"])
                    result = updateRow(contents, [], values, get(_USERS_DB(), 1), db)       
                    result
                else
                    :error_no_admin
                end
            else
                :error_no_db
            end
            "Info" -> data = getData(get(_INFO_DB(), 0))
            if(data != :error_no_db) do
                if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do
                    contents = String.split(data, ["\n", "-"])
                    result = updateRow(contents, [], values, get(_INFO_DB(), 1), db)
                    result
                else
                    :error_no_admin
                end
            else
                :error_no_db
            end
            "Session" -> data = getData(get(_SESSIONS_DB(), 0))
            if(data != :error_no_db) do 
                if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do    
                    contents = String.split(data, ["\n", "-"])
                    result = updateRow(contents, [], values, get(_SESSIONS_DB(), 1), db)    
                    result
                else
                    :error_no_admin
                end
            else
                msg("Session db doesn't exists")
                :error_no_db
            end
            _ -> msg("Can't select DB") 
            :error_db
        end
    end
    
    @doc """
        Delete a row in DB
    """
    def delete(values, user, db) do
        case db do 
            "Users" -> data = getData(get(_USERS_DB(), 0))
            if(data != :error_no_db) do
                if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do
                    contents = String.split(data, ["\n", "-"])
                    result = deleteRow(contents, [], values, 0, get(_USERS_DB(), 1), db)       
                    result
                else
                    :error_no_admin
                end
            else
                :error_no_db
            end
            "Info" -> data = getData(get(_INFO_DB(), 0))
            if(data != :error_no_db) do
                if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do
                    contents = String.split(data, ["\n", "-"])
                    result = deleteRow(contents, [], values, 0, get(_INFO_DB(), 1), db)
                    result
                else
                    :error_no_admin
                end
            else
                :error_no_db
            end
            "Session" -> data = getData(get(_SESSIONS_DB(), 0))
            if(data != :error_no_db) do 
                if(checkIfAdmin(_ADMIN_USERS(), user) != :error_no_admin) do    
                    contents = String.split(data, ["\n", "-"])
                    result = deleteRow(contents, [], values, 0, get(_SESSIONS_DB(), 1), db)    
                    result
                else
                    :error_no_admin
                end
            else
                msg("Session db doesn't exists")
                :error_no_db
            end
            _ -> msg("Can't select DB") 
            :error_db
        end
    end

    defp checkIfAdmin([], _user) do
        :error_no_admin
    end
    defp checkIfAdmin([h|t], user) do
        if (h != user) do
            checkIfAdmin(t, user)
        else
            :ok
        end
    end

    defp get([h|t], n) do
        if (t != [] && n > 0) do
            get(t, n-1)
        else
            h
        end
    end

    defp searchOrAnd([], _) do
        :error_user_not_found
    end 
    defp searchOrAnd(l, val) do
        [h|t] = l
        if (t != []) do
            [h2|t2] = t
            if(t2 != []) do
                [h3|t3] = t2
                if(t3 != []) do
                    [h4|t4] = val
                    [h5|_] = t4
                    if((h==h4 || h2==h4) && h3 == h5) do
                        [h, h2, h3]
                    else
                        searchOrAnd(t3, val)
                    end
                else
                    :error_user_not_found
                end
            else
                :error_user_not_found
            end
        else
            :error_user_not_found
        end
    end

    defp searchRow([], _) do
        :error_user_not_found
    end 
    defp searchRow(l, val) do
        [h|t] = l
        if (t != []) do
            [h2|t2] = t
            if (t2 != []) do
                [_|t3] = t2
                if(t3 != []) do
                    [h4|_] = val
                    if (h2 == h4 || h == h4) do
                        [h, h2]
                    else
                        searchRow(t3, val)
                    end
                else
                    :error_user_not_found
                end
            else
                :error_user_not_found
            end
        else
            :error_user_not_found
        end
    end
    defp searchRow([], _, _n) do
        :error_user_not_found
    end 
    defp searchRow(l, val, n) do
        [h|t] = l
        if (t != []) do
            [h2|t2] = t
            if (t2 != []) do
                [h3 | t3] = t2
                if(t3 != []) do
                    [h4 | t4] = t3
                    [h5 | t5] = t4
                    [h6|_] = val
                    if (h == h6 || h2 == h6) do
                        [h, h2, h3, h4, h5]
                    else
                        searchRow(t5, val, n)
                    end
                else
                    :error_user_not_found
                end
            else
                :error_user_not_found
            end
        else
            :error_user_not_found
        end
    end

    defp updateRow([], l, _, ls, db) do
        #drop(db)
        drop("root", db)
        #Add all lines l to new file
        toTextFileConversor(l, [], 0, ls, db)
        :ok
        
    end
    defp updateRow(data, l, values, ls, db) do
        [h|t] = data
        [hv|tv] = values
        if(h == hv) do
            [hv2|tv2] = tv
            [_ | t2] = t
            if (tv2 != []) do
                [hv3|tv3] = tv2
                [_ | t3] = t2
                if (tv3 != []) do
                    [hv4|tv4] = tv3
                    [_ | t4] = t3
                    if (tv4 != []) do
                        [hv5| _ ] = tv4
                        [_ | t5] = t4
                        toAdd = [hv5, hv4, hv3, hv2, hv]
                        updateRow(t5, toAdd++l, values, ls, db)
                    else
                        toAdd = [hv4, hv3, hv2, hv]
                        updateRow(t4, toAdd++l, values, ls, db)
                    end
                else
                    toAdd = [hv3, hv2, hv]
                    updateRow(t3, toAdd++l, values, ls, db)
                end
            else
                toAdd = [hv2, hv]
                updateRow(t2, toAdd++l, values, ls, db)
            end
        else
            updateRow(t, [h|l], values, ls, db)
        end
    end

    defp deleteRow([], l, _values, _ls, lt, db) do
        #drop(db)
        drop("root", db)
        #Add all lines l to new file
        toTextFileConversor(l, [], 0, lt, db)
        :ok
        
    end
    defp deleteRow(data, l, values, ls, lt, db) do
        [h|t] = data
        [hv|_] = values
        if(h == hv || ls > 0) do
            if(ls == (lt-1)) do
                deleteRow(t, l, values, 0, lt, db)
            else
                deleteRow(t, l, values, ls+1, lt, db)
            end
        else
            deleteRow(t, [h|l], values, 0, lt, db)
        end
    end

    defp toTextFileConversor([], result, _n, _ls, _db) do
        result
    end
    defp toTextFileConversor([h|t], result, n, ls, db) do
        if (h == "\n" || h == " " || h == "" || h == "\t" || h == "\r") do
            toTextFileConversor(t, result, n, ls, db)
        else
            if (n == (ls-1)) do
                toAdd = [h]
                insert(toAdd++result, "app", db)
                toTextFileConversor(t, [], 0, ls, db)
            else
                toTextFileConversor(t, [h | result], n+1, ls, db)
            end
        end
    end

    defp getData(path) do
        d = File.read(path)
        case d do
            {:ok, data} -> data
            {:error, _} -> :error_no_db
        end
    end

    defp search([], _, _) do 
        :error_user_not_found 
    end
    defp search([h|t], n, val) do 
        if (h == val && Kernel.rem(n, 3) != 0) do
            [h]
        else
            search(t, n+1, val)
        end
    end

    defp msg(text) do
        IO.puts "DB: #{text}"
    end
end