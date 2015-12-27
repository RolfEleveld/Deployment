Configuration DevelopmentMachineConfiguration {
    param(
        [string[]]$computerName="localhost"
    )
    Node $computerName {
        User AddRolf {
            UserName = "rolf@bajomero.com"
            Ensure = "Present"
        }
        Group InsureRolfInAdmins {
            GroupName = "Administrators"
            Ensure = "Present"
            MembersToInclude = "rolf@bajomero.com"
        }
    }
}