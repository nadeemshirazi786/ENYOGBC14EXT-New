page 50040 "Market Basket Export Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Market Basket Export Setup";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Destination Folder Path"; "Destination Folder Path")
                {
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        "Destination Folder Path" := gcduFileManagement.BrowseForFolderDialog('', "Destination Folder Path", TRUE);
                    end;
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        RESET;
        IF NOT GET THEN BEGIN
            INIT;
            INSERT;
        END;
    end;
    var
        gcduFileManagement: Codeunit "File Management";
}