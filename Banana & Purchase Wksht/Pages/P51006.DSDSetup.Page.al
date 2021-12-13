page 51006 "DSD Setup"
{
    PageType = Card;
    ApplicationArea = all;
    UsageCategory = Administration;
    SourceTable = "DSD Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Route Pack Reclass Jnl. Templ."; "Route Pack Reclass Jnl. Templ.")
                {
                    MultiLine = true;
                }
                field("Route Pack Reclass Jnl. Batch"; "Route Pack Reclass Jnl. Batch")
                {
                    MultiLine = true;
                }
                field("Route Pick Report ID"; "Route Pick Report ID")
                {
                }
                field("Item Pick Report ID"; "Item Pick Report ID")
                {
                }
                field("Auto-Refresh Pick Forms"; "Auto-Refresh Pick Forms")
                {
                }
                field("Sort Order Lines By"; "Sort Order Lines By")
                {
                }
                field("Blocked Items on Activate"; "Blocked Items on Activate")
                {
                }
                field("RP Reclass Jnl. Posting Date"; "RP Reclass Jnl. Posting Date")
                {
                }
            }
            group(Manufacturing)
            {
                Caption = 'Manufacturing';
                field("Hide Wksht. Transfer Actions"; "Hide Wksht. Transfer Actions")
                {
                }
            }
            group("Route Template")
            {
                Caption = 'Route Template';
                field("Orders Use Template Route"; "Orders Use Template Route")
                {
                }
                field("Override Loc. from Route Temp."; "Override Loc. from Route Temp.")
                {
                }
                field("Match S. Line Rte. on Hdr. Chg"; "Match S. Line Rte. on Hdr. Chg")
                {
                }
                field("Unassigned Location Code"; "Unassigned Location Code")
                {
                }
                field("Std. Dlvry. Always Print CM"; "Std. Dlvry. Always Print CM")
                {
                }
                field("B.Post Del. 0-Qty S. Headers"; "B.Post Del. 0-Qty S. Headers")
                {
                }
                field("Pre-Invoice Order Report ID"; "Pre-Invoice Order Report ID")
                {
                    LookupPageID = Objects;
                }
                field("Pre-Invoice Order Report Name"; "Pre-Invoice Order Report Name")
                {
                }
                field("Alternate Order Report ID"; "Alternate Order Report ID")
                {
                    LookupPageID = Objects;
                }
                field("Alternate Order Report Name"; "Alternate Order Report Name")
                {
                }
                field("Stales CM Report ID"; "Stales CM Report ID")
                {
                    LookupPageID = Objects;
                }
                field("Stales CM Report Name"; "Stales CM Report Name")
                {
                }
                field("Stales CM Return Reason Code"; "Stales CM Return Reason Code")
                {
                }
                field("Invoice Report ID"; "Invoice Report ID")
                {
                    LookupPageID = Objects;
                }
                field("Invoice Report Name"; "Invoice Report Name")
                {
                }
                field("Cr. Memo Report ID"; "Cr. Memo Report ID")
                {
                    LookupPageID = Objects;
                }
                field("Cr. Memo Report Name"; "Cr. Memo Report Name")
                {
                }
                fixed("Standard Delivery Days")
                {
                    group(M)
                    {
                        Caption = 'M';
                        field("Standard Delivery Mon"; "Standard Delivery Mon")
                        {
                            Caption = 'Std. Delivery';
                        }
                        field("Alt. Delivery Mon"; "Alt. Delivery Mon")
                        {
                            Caption = 'Alt. Delivery';
                        }
                    }
                    group(T)
                    {
                        Caption = 'T';
                        field("Standard Delivery Tues"; "Standard Delivery Tues")
                        {
                            Caption = 'T';
                        }
                        field("Alt. Delivery Tues"; "Alt. Delivery Tues")
                        {
                            Caption = 'T';
                        }
                    }
                    group(W)
                    {
                        Caption = 'W';
                        field("Standard Delivery Weds"; "Standard Delivery Weds")
                        {
                            Caption = 'W';
                        }
                        field("Alt. Delivery Weds"; "Alt. Delivery Weds")
                        {
                            Caption = 'W';
                        }
                    }
                    group(Th)
                    {
                        Caption = 'Th';
                        field("Standard Delivery Thurs"; "Standard Delivery Thurs")
                        {
                            Caption = 'Th';
                        }
                        field("Alt. Delivery Thurs"; "Alt. Delivery Thurs")
                        {
                            Caption = 'Th';
                        }
                    }
                    group(F)
                    {
                        Caption = 'F';
                        field("Standard Delivery Fri"; "Standard Delivery Fri")
                        {
                            Caption = 'F';
                        }
                        field("Alt. Delivery Fri"; "Alt. Delivery Fri")
                        {
                            Caption = 'F';
                        }
                    }
                    group(S)
                    {
                        Caption = 'S';
                        field("Standard Delivery Sat"; "Standard Delivery Sat")
                        {
                            Caption = 'S';
                        }
                        field("Alt. Delivery Sat"; "Alt. Delivery Sat")
                        {
                            Caption = 'S';
                        }
                    }
                    group(Su)
                    {
                        Caption = 'Su';
                        field("Standard Delivery Sun"; "Standard Delivery Sun")
                        {
                            Caption = 'Su';
                        }
                        field("Alt. Delivery Sun"; "Alt. Delivery Sun")
                        {
                            Caption = 'Su';
                        }
                    }
                }
            }
            group(Rules)
            {
                Caption = 'Rules';
                field("Activate Cut Off Times"; "Activate Cut Off Times")
                {
                }
                field("Cut Off Time Monday"; "Cut Off Time Monday")
                {
                }
                field("Cut Off Time Tuesday"; "Cut Off Time Tuesday")
                {
                }
                field("Cut Off Time Wednesday"; "Cut Off Time Wednesday")
                {
                }
                field("Cut Off Time Thursday"; "Cut Off Time Thursday")
                {
                }
                field("Cut Off Time Friday"; "Cut Off Time Friday")
                {
                }
                field("Cut Off Time Saturday"; "Cut Off Time Saturday")
                {
                }
                field("Cut Off Time Sunday"; "Cut Off Time Sunday")
                {
                }
                field("Qck. Ord. Lead Time Mon (Days)"; "Qck. Ord. Lead Time Mon (Days)")
                {
                }
                field("Qck. Ord. Lead Time Tue (Days)"; "Qck. Ord. Lead Time Tue (Days)")
                {
                }
                field("Qck. Ord. Lead Time Wed (Days)"; "Qck. Ord. Lead Time Wed (Days)")
                {
                }
                field("Qck. Ord. Lead Time Thu (Days)"; "Qck. Ord. Lead Time Thu (Days)")
                {
                }
                field("Qck. Ord. Lead Time Fri (Days)"; "Qck. Ord. Lead Time Fri (Days)")
                {
                }
                field("Qck. Ord. Lead Time Sat (Days)"; "Qck. Ord. Lead Time Sat (Days)")
                {
                }
                field("Qck. Ord. Lead Time Sun (Days)"; "Qck. Ord. Lead Time Sun (Days)")
                {
                }
            }
            
        }
        
        
    }
    
}

