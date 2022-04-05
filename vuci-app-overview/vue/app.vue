<template>
  <div class="container">
    <a-button class="settings-button" type="primary" @click="showDrawer">
      Settings
    </a-button>
    <a-drawer
      title="Overview settings"
      placement="right"
      :visible="visible"
      @close="onClose"
    >
      <div v-for="item in items" :key="item.id">
        <a-checkbox :defaultChecked="item.checked" @change="handleCheck(item.id)">{{ item.name }}</a-checkbox>
      </div>
    </a-drawer>
    <div class="card-container">
      <template v-for='(item, idx) in items'>
        <div v-if="item.checked" :key="idx" draggable @dragstart="startDrag($event, item)" @drop="onDrop($event, item.order)" @dragover.prevent @dragenter.prevent>
          <Card v-if="item.name === 'System'" :title="item.name">
            <div class="group">
              <div class="grouped-info">
                <label style="color: #1890ff">CPU usage</label>
                <a-progress :percent="cpuPercentage" />
              </div>
              <div class="grouped-info">
                <label style="color: #1890ff">Memory usage</label>
                <a-progress :percent="memPercentage" />
              </div>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <label>Router uptime</label>
              <span>{{ sysInfo.uptime }}</span>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <label>Local device time</label>
              <span>{{ sysInfo.local_time }}</span>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <label>Firmware version</label>
              <span>{{ sysInfo.firmware }}</span>
            </div>
          </Card>
          <Card v-else-if="item.name === 'LAN'" :title="item.name">
            <div class="grouped-info">
              <label>Type</label>
              <span>{{ lanInterface && lanInterface.status && lanInterface.status.device ? `Wired (${lanInterface.status.device})` : '' }}</span>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <label>IP address</label>
              <span>{{ lanInterface && lanInterface.status && lanInterface.status['ipv4-address'] ? `${lanInterface.status['ipv4-address'][0].address}/${lanInterface.status['ipv4-address'][0].mask}` : '-' }}</span>
            </div>
          </Card>
          <Card v-else-if="item.name === 'WAN'" :title="item.name">
            <div class="grouped-info">
              <div class="tagged">
                <label>Type</label>
                <a-tag color="green">wan</a-tag>
              </div>
              <span>{{ wanInterface && wanInterface.status && wanInterface.status.device ? `Wired (${wanInterface.status.device})` : '' }}</span>
            </div>
            <div class="grouped-info">
              <label>IP address</label>
              <span>{{ wanInterface && wanInterface.status && wanInterface.status['ipv4-address'] ? `${wanInterface.status['ipv4-address'][0].address}/${wanInterface.status['ipv4-address'][0].mask}` : '-' }}</span>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <div class="tagged">
                <label>Type</label>
                <a-tag color="green">wan6</a-tag>
              </div>
              <span>{{ wan6Interface && wan6Interface.status && wan6Interface.status.device ? `Wired (${wan6Interface.status.device})` : '' }}</span>
            </div>
            <div class="grouped-info">
              <label>IP address</label>
              <span>{{ wan6Interface && wan6Interface.status && wan6Interface.status['ipv4-address'] ? `${wan6Interface.status['ipv4-address'][0].address}/${wan6Interface.status['ipv4-address'][0].mask}` : '-' }}</span>
            </div>
          </Card>
          <Card v-else-if="item.name === 'Recent System Events'" :title="item.name">
            <div class="grouped-info" v-for="log in sysLog" :key="log.id">
              <div class="tagged">
                <label>{{ log.datetime }}</label>
                <a-tag :color="getLogStatusColor(log.level)">{{log.level}}</a-tag>
              </div>
              <span>{{ log.msg }}</span>
              <a-divider style="margin-top:10px"/>
            </div>
          </Card>
          <Card v-else-if="item.name === 'Access Control'" :title="item.name">
            <div class="grouped-info">
              <label>LAN</label>
              <span>{{ getEnabledPorts('lan') }}</span>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <label>WAN</label>
              <span>{{ getEnabledPorts('wan') }}</span>
            </div>
          </Card>
          <Card v-else-if="item.name === 'Wireless (radio0)'" :title="item.name">
            <div class="grouped-info">
              <label>SSID</label>
              <span>{{ wifi && wifi[0] && wifi[0].ssid ? wifi[0].ssid : '-' }}</span>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <label>Interface</label>
              <span>{{ wifi && wifi[0] && wifi[0].network ? wifi[0].network : '-' }}</span>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <label>IP address</label>
              <span>{{ simInterface && simInterface.status && simInterface.status['ipv4-address'] ? `${simInterface.status['ipv4-address'][0].address}/${simInterface.status['ipv4-address'][0].mask}` : '-' }}</span>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <label>Encryption type</label>
              <span>{{ wifi && wifi[0] && wifi[0].encryption ? encryptions[wifi[0].encryption.split('+')[0]] : 'No encryption' }}</span>
            </div>
          </Card>
          <Card v-else-if="item.name === 'Wireless (radio1)'" :title="item.name">
            <div class="grouped-info">
              <label>SSID</label>
              <span>{{ wifi && wifi[1] && wifi[1].ssid ? wifi[1].ssid : '-' }}</span>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <label>Interface</label>
              <span>{{ wifi && wifi[1] && wifi[1].network ? wifi[1].network : '-' }}</span>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <label>IP address</label>
              <span>{{ simInterface && simInterface.status && simInterface.status['ipv4-address'] ? `${simInterface.status['ipv4-address'][0].address}/${simInterface.status['ipv4-address'][0].mask}` : '-' }}</span>
            </div>
            <a-divider/>
            <div class="grouped-info">
              <label>Encryption type</label>
              <span>{{ wifi && wifi[1] && wifi[1].encryption ? encryptions[wifi[1].encryption.split('+')[0]] : 'No encryption' }}</span>
            </div>
          </Card>
        </div>
      </template>
    </div>
  </div>
</template>

<script>
import Card from './components/Card.vue'

export default {
  components: {
    Card
  },
  data () {
    return {
      configFile: 'view',
      visible: false,
      sysInfo: {},
      sysLog: [],
      lanInterface: {},
      wanInterface: {},
      wan6Interface: {},
      simInterface: {},
      interfaces: [],
      wifi: [],
      cpuPercentage: 0,
      memPercentage: 0,
      encryptions: {
        none: 'No encryption',
        psk: 'WPA-PSK',
        psk2: 'WPA2-PSK',
        'psk-mixed': 'WPA/WPA2-PSK Mixed'
      },
      ssh: {
        cfg: '',
        lan: '',
        wan: {
          enabled: false,
          cfg: null
        },
        port: '22'
      },
      webui: {
        wanHTTP: {
          cfg: null,
          enabled: false,
          port: '80'
        }
      },
      uhttpd: {
        initial: '',
        http: true
      },
      cli: {
        lan: false,
        wan: {
          enabled: false,
          cfg: ''
        },
        portRange: ''
      },
      items: [
        {
          id: 0,
          title: 'item1',
          name: 'System',
          checked: false,
          order: 0
        },
        {
          id: 1,
          title: 'item2',
          name: 'Access Control',
          checked: false,
          order: 1
        },
        {
          id: 2,
          title: 'item3',
          name: 'WAN',
          checked: false,
          order: 2
        },
        {
          id: 3,
          title: 'item4',
          name: 'Wireless (radio0)',
          checked: false,
          order: 3
        },
        {
          id: 4,
          title: 'item5',
          name: 'Recent System Events',
          checked: false,
          order: 4
        },
        {
          id: 5,
          title: 'item6',
          name: 'LAN',
          checked: false,
          order: 5
        },
        {
          id: 6,
          title: 'item7',
          name: 'Wireless (radio1)',
          checked: false,
          order: 6
        }
      ]
    }
  },
  timers: {
    update: { time: 1000, autostart: true, immediate: true, repeat: true },
    updateSystemLogs: { time: 5000, autostart: true, immediate: true, repeat: true },
    updateCpuUsage: { time: 1000, autostart: true, immediate: true, repeat: true }
  },
  methods: {
    async load () {
      await this.$uci.load(this.configFile)
      if (this.$uci.state.values.view == null || this.$uci.state.values.view.length === 0) return
      this.items = Object.values(this.$uci.state.values.view)
        .map(v => {
          v.title = v['.name']
          v.id = parseInt(v.id)
          v.order = parseInt(v.order)
          v.checked = typeof v.checked === 'string' ? v.checked === '1' : v.checked
          return v
        })
        .sort((a, b) => (a.order > b.order) ? 1 : ((b.order > a.order) ? -1 : 0))
    },
    saveConfig () {
      this.$uci.save().then(() => {
        this.$uci.apply().then(() => {
          this.load()
        })
      })
    },
    startDrag (e, item) {
      e.dataTransfer.dropEffect = 'move'
      e.dataTransfer.effectAllowed = 'move'
      e.dataTransfer.setData('itemID', item.order)
    },
    onDrop (e, to) {
      const from = parseInt(e.dataTransfer.getData('itemID'))
      if (from === to) return
      const item1 = this.items.find(item => item.order === parseInt(from))
      const item2 = this.items.find(item => item.order === to)
      item2.order = from
      item1.order = to
      this.updateItem(item1)
      this.updateItem(item2)
      this.saveConfig()
    },
    updateItem (item) {
      this.$uci.set(this.configFile, item.title, 'id', item.id)
      this.$uci.set(this.configFile, item.title, 'order', item.order)
      this.$uci.set(this.configFile, item.title, 'checked', item.checked ? 1 : 0)
    },
    showDrawer () {
      this.visible = true
    },
    onClose () {
      this.visible = false
    },
    handleCheck (value) {
      const item = this.items.find(item => item.id === value)
      item.checked = !item.checked
      this.$uci.set(this.configFile, item.title, 'checked', item.checked ? 1 : 0)
      if (item.name === 'System') {
        if (item.checked) {
          this.$timer.start('update')
          this.$timer.start('updateCpuUsage')
        } else {
          this.$timer.stop('update')
          this.$timer.stop('updateCpuUsage')
        }
      }
      if (item.name === 'Recent System Events') item.checked ? this.$timer.start('updateSystemLogs') : this.$timer.stop('updateSystemLogs')
      this.saveConfig()
    },
    getInterface (name) {
      return this.interfaces.filter(iface => iface.name === name)[0]
    },
    loadInterfaces () {
      this.$network.load().then(() => {
        this.interfaces = this.$network.getInterfaces()
        this.lanInterface = this.getInterface('lan')
        this.wanInterface = this.getInterface('wan')
        this.wan6Interface = this.getInterface('wan6')
        this.simInterface = this.getInterface('mob1s1a1_4')
      })
    },
    getEnabledPorts (name) {
      var enabledString = ''
      if (name === 'lan') {
        if (this.ssh.lan) enabledString += 'SSH '
        if (this.uhttpd.http) enabledString += 'HTTP '
        if (this.cli.lan) enabledString += 'CLI'
      } else {
        if (this.ssh.wan.enabled) enabledString += 'SSH '
        if (this.webui.wanHTTP.enabled) enabledString += 'HTTP '
        if (this.cli.wan.enabled) enabledString += 'CLI'
      }
      if (enabledString === '') enabledString += `No enabled ports on ${name}.`
      return enabledString
    },
    getLogStatusColor (level) {
      switch (level) {
        case 'warn':
          return 'orange'
        case 'info':
          return 'blue'
        case 'notice':
          return 'cyan'
        default:
          return 'purple'
      }
    },
    updateCpuUsage () {
      this.$rpc.call('system', 'cpu_time').then(times => {
        if (!this.lastCPUTime) {
          this.cpuPercentage = 0
          this.lastCPUTime = times
          return
        }
        const idle1 = this.lastCPUTime[3]
        const idle2 = times[3]
        let total1 = 0
        let total2 = 0
        this.lastCPUTime.forEach(t => {
          total1 += t
        })
        times.forEach(t => {
          total2 += t
        })
        this.cpuPercentage = Math.floor(((total2 - total1 - (idle2 - idle1)) / (total2 - total1)) * 100)
        this.lastCPUTime = times
      })
    },
    updateSystemLogs () {
      this.$rpc.call('system', 'syslog').then(({ log }) => {
        this.sysLog = log.map((v, i) => {
          v.key = i
          return v
        }).slice(-3)
      })
    },
    update () {
      this.$system.getInfo().then(({ hostname, model, system, release, kernel, localtime, uptime, memory }) => {
        this.sysInfo = {
          hostname,
          model,
          system,
          firmware: release.revision,
          kernel,
          local_time: new Date(localtime * 1000).toLocaleString(),
          uptime: '%t'.format(uptime)
        }
        this.memPercentage = Math.floor(((memory.total - memory.free) / memory.total) * 100)
      })
    },
    async loadFirewallSettings () {
      await this.$uci.load('firewall')
      this.$uci.sections('firewall', 'rule').forEach(rule => {
        switch (rule.name) {
          case 'Enable_SSH_WAN':
            this.ssh.wan.enabled = rule.enabled === '1'
            this.ssh.wan.cfg = rule['.name']
            break
          case 'Enable_HTTP_WAN':
            this.webui.wanHTTP.enabled = rule.enabled === '1'
            this.webui.wanHTTP.port = rule.dest_port
            this.webui.wanHTTP.cfg = rule['.name']
            break
          case 'Enable_CLI_WAN':
            this.cli.wan.enabled = rule.enabled === '1'
            this.cli.wan.cfg = rule['.name']
            this.cli.portRange = rule.dest_port
            break
          default:
            break
        }
      })
    },
    async loadCliSettings () {
      await this.$uci.load('cli')
      this.cli.lan = this.$uci.get('cli', 'status', 'enable') === '1'
    },
    async createFile () {
      await this.$rpc.call('overview', 'create_file', { })
    }
  },
  async created () {
    await this.load()
    this.$uci.set('test')
    this.saveConfig()
    if (this.$uci.state.values.view == null || Object.keys(this.$uci.state.values.view).length === 0) {
      await this.createFile()
      this.items.map(item => {
        this.$uci.add(this.configFile, 'view', item.title)
        this.$uci.set(this.configFile, item.title, 'id', item.id)
        this.$uci.set(this.configFile, item.title, 'name', item.name)
        this.$uci.set(this.configFile, item.title, 'order', item.order)
        this.$uci.set(this.configFile, item.title, 'checked', 1)
      })
      this.saveConfig()
    }
    this.loadInterfaces()
    await this.$uci.load('dropbear')
    this.ssh.cfg = this.$uci.sections('dropbear')[0]['.name']
    this.ssh.lan = this.$uci.sections('dropbear')[0].enable === '1'
    this.ssh.port = this.$uci.sections('dropbear')[0].Port
    this.loadFirewallSettings()
    this.loadCliSettings()
    await this.$uci.load('vuci-httpd')
    this.uhttpd.http = this.$uci.get('vuci-httpd', 'main', 'enabled') === '1'
    this.uhttpd.initial = this.uhttpd.http
    this.$uci.load('wireless').then(() => {
      this.wifi = this.$uci.sections('wireless', 'wifi-iface')
    })
  }
}
</script>

<style>
.container {
  width: 100%;
  margin: auto;
  padding: 50px 100px 100px 100px;
}
.card-container {
  display: flex;
  justify-content: flex-start;
  flex-wrap: wrap;
  row-gap: 20px;
  column-gap: 20px;
}
.settings-button {
  position: fixed;
  right: 0;
  top: 40%;
  z-index: 10;
}
</style>
