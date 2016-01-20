Configuration DevelopmentMachineConfiguration {
    param(
        [string]$MachineName="localhost"
    )

    Import-DscResource –ModuleName ’PSDesiredStateConfiguration’

    Node $MachineName {
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