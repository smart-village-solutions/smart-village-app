workspace "smart-village-app" {
    !identifiers hierarchical

    model {
        user = person "SVA User" "Nutzer der eine Smart Village App auf dem Handy nutzt" "User"
        data_provider = person "Datenlieferant" "Datenanbieter für Imports oder Echtzeitdate" "Data Provider"
        extternal_websites = softwareSystem "Externe Websites" "Externe Websites die nützliche Widgets besitzen" "External Websites"
        external_data_sources = softwareSystem "Externe Datenquellen" "Externe Quellen in beliebigen Datenformaten" "External Quellen"

        // enterprise "SVS" {
            admin = person "App Admin" "Admin der die App konfiguriert" "Admin"

            datahub_group = group "Smart-Village-Server" {
                sva_server = softwareSystem "SV Mainserver" "Sammelstelle externer Datenquellen die in Echtzeit dem Digitransit zur Verfügung gestellt werden" {
                    db = container "Datenbank" "Datenbank für die Echtzeitdaten" "Database"
                    app = container "SV App" "Stellt die APIs bereit" "SV App"
                    cron_job = container "Datahub Cron Job" "Maintenance Tasks" "Datahub Cron Job"
                    delayed_job = container "Delayed Job" "Hintergrunddienste, Benachrichtignungsdienst" "Delayed Job"
                    redis = container "Redis" "Cache" "Redis"
                    // nginx = container "Nginx" "Reverse Proxy" "Nginx"
                }
                sva_cms = softwareSystem "SVA CMS" "Content Management System für die Datenlieferanten und Admins" "Datahub CMS"
                minio = softwareSystem "Minio" "S3 Storage"
                // wordpress = softwareSystem "Wordpress Landingpage" "Wordpress für eine Landingpage" "Wordpress"
                node_red = softwareSystem "Node Red" "Node Red für die Datenlieferanten" "Node Red"
                bb_bus = softwareSystem "BUS" "Bürger und Unternehmensservice"
                // traefik = softwareSystem "Traefik" "Reverse Proxy" "Traefik"
            }
            sv_app = softwareSystem "Smart Village App" "React Native App für iOS/Android" "Mobile App"
        // }

        # Monitoring Services
        monitoring = softwareSystem "Monitoring und Logs" "Sammelstelle für Logs und Monitoring" "Monitor" {
            pn_group = group "Planetary Networks"{
                prometheus = container "Prometheus" "PN Monitoring System"{
                    url "http://prometheus.planetary-networks.de"
                }
                loki = container "Loki" "PN Logging System"
            }
            grafana = container "Grafana" "Monitoring" "Grafana" {
                url "https://logs.tpwd.de"
            }
            metrics_collector = container "Metrics Collector" "Sammelt Metriken" "Metrics Collector"
            matomo = container "Matomo" "Analytics" "Matomo"
            uptime_robot = container "Uptime Robot" "Monitoring" "Uptime Robot"
            rollbar = container "Rollbar" "Error Logs" "Error Logs"
            alerts = container  "Alerts" "Notifications"{
                slack = component "Slack"
                email = component "Email"
            }
        }

        # Relations

        # datahub internal relations
        sva_server.app -> sva_server.db "Schreibt Daten in"
        sva_cms -> sva_server.app "Sendet Daten per GraphQl an"
        sva_server.cron_job -> sva_server.app "Startet Tasks für Wartungsarbeiten"
        sva_server.app -> sva_server.delayed_job "Startet Hintergrunddienste"
        sva_server.app -> sva_server.redis "Schreibt Daten in"

        sv_app -> sva_server.app "Lädt Daten von"
        sv_app -> extternal_websites "Zeigt Daten an von"
        sv_app -> bb_bus "Lädt Daten von"
        sva_server.app -> minio "Schreibt Daten in"
        sva_cms -> minio "Schreibt Daten in"
        node_red -> sva_server.app "Schreibt Daten in"
        node_red -> external_data_sources "Lädt und konvertiert Daten von"
        // sva_server.nginx -> sva_server.app "Stellt HTML bereit"

        # User Relations
        user -> sv_app "Nutzt"
        // user -> wordpress "Nutzt"
        sv_app -> minio "Lädt direkt Daten von"
        admin -> sva_cms "Kontrolliert Datenbestand"
        admin -> sva_server.app "Verwaltet Datenlieferanten"
        data_provider -> sva_cms "Trägt daten von Hand ein"
        // traefik -> sva_server.nginx "Leitet externe Anfragen an den richtigen Server weiter"

        # Monitoring Relations
        // monitoring.prometheus -> monitoring.metrics_collector "Sammelt Daten von"
        monitoring.grafana -> monitoring.prometheus  "Sammelt Daten von"
        monitoring.grafana -> monitoring.loki  "Sammelt Daten von"
        monitoring.grafana -> monitoring.alerts.slack "Sendet Alerts zu"
        monitoring.grafana -> monitoring.alerts.email "Sendet Alerts zu"
        bb_bus -> monitoring.loki "Schreibt Log-Daten zu"
        sva_server -> monitoring.loki "Schreibt Log-Daten zu"
        sva_cms -> monitoring.loki "Schreibt Log-Daten zu"
        monitoring.uptime_robot -> monitoring.alerts.slack "Sendet Alerts zu"
        // monitoring.uptime_robot -> monitoring.alerts.email "Sendet Alerts zu"
        // monitoring.uptime_robot.datahub_vector_tile -> sva_server.tile_server "Überwacht"
        // monitoring.uptime_robot.datahub_web_ui -> sva_server.app "Überwacht"
        // monitoring.uptime_robot.otp_prod -> otp "Überwacht"
        // monitoring.uptime_robot.otp_prod_key -> otp "Überwacht"
        // monitoring.uptime_robot.otp_staging -> otp_staging "Überwacht"
        // monitoring.uptime_robot.otp_staging_key -> otp_staging "Überwacht"


    }

    views {
        systemlandscape "Systemlandschaft" {
            include *
            autolayout
        }

        container sva_server "SV-Mainserver" {
            include *
            autoLayout
        }

        // systemcontext amarillo "Amarillo" {
        //     include *
        //     autoLayout
        // }

        // container amarillo "Amarillo-System" {
        //     include *
        //     autoLayout
        // }

        styles {
            element "Group" {
                color #000000
            }
            element "Mobile App" {
                background #ff0000
            }
        }

        theme default
    }

}
