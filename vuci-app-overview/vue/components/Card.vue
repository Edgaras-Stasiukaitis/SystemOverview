<template>
    <a-card class="card" :title="title">
      <div class="info">
        <slot></slot>
      </div>
    </a-card>
</template>

<script>
export default {
  props: ['title']
}
</script>

<style>
.info {
  display: flex;
  flex-direction: column;
  flex-direction: flex-start;
  row-gap: 15px;
}
.group {
  width: 100%;
  display: flex;
  flex-direction: row;
  column-gap: 25px;
}
.grouped-info {
  width: 100%;
  display: flex;
  flex-direction: column;
}
.grouped-info label {
  font-weight: bold;
}
.grouped-info span {
  font-size: 12px;
  color: gray;
}
.tagged {
  display: flex;
  flex-direction: row;
  column-gap: 5px;
}
.tagged span {
  color: black;
}
.card {
  width: 450px;
  height: 350px;
  box-shadow: rgba(60, 64, 67, 0.3) 0px 1px 2px 0px, rgba(60, 64, 67, 0.15) 0px 2px 6px 2px;
}
.card:hover {
  border: 1px solid #1890ff;
}
.ant-card-head-title {
  font-weight: bold;
}
.ant-divider-horizontal {
  margin: 0;
}
</style>
