---
title: BaseLogic
category: [项目]
tags: []
date: 2020-11-14 09:52:51
---



```php
<?php

namespace App\HttpController\Common\Logic;

use EasySwoole\ORM\AbstractModel;
// use EasySwoole\Http\Request;
class BaseLogic extends AbstractModel
{
    // 操作状态
    const MODEL_INSERT          =   1;      //  插入模型数据
    const MODEL_UPDATE          =   2;      //  更新模型数据
    const MODEL_BOTH            =   3;      //  包含上面两种方式
    const MUST_VALIDATE         =   1;      // 必须验证
    const EXISTS_VALIDATE       =   0;      // 表单存在字段则验证
    const VALUE_VALIDATE        =   2;      // 表单值不为空则验证

    public $data     = [];
    public $old_data = []; // public才会根据协程清除
    public $tmp_data = []; // public才会根据协程清除
    public $request_user = []; 
    public $request_user_id = 0;

    public $patchValidate = false; // 是否批处理验证

    public $handle_sence;
    public $scene_id; // 未兼容老版本，此字段与handle_sence相同
    
    protected $handle_field_arr = [];
    protected $handle_logs = [];
    protected $cur_sence_field;
    protected $allow_fields;
    protected $db_allow_fields;

    //修改插入后自动完成
    protected $logic_auto = array();
    protected $logic_validate = array();

    public function init($request){
        $this->request_user = $request->getAttribute('request_user');
        $this->request_user_id = (int)$this->request_user['id'];
        return $this;
    }

    public function request_user_id(){
        return $this->request_user_id;
    }

    public function getRequestUser(){
        return $this->request_user;
    }

    public function getError(){
        return $this->error;
    }

    public function getSaveData(){
        return $this->data;
    }

    public function getOldData(){
        return $this->old_data;
    }

    public function run($post_data,$handle_sence){
        $this->data         = null;
        $this->data         = $post_data;
        $this->handle_sence = $handle_sence;
        $this->scene_id     = $handle_sence;
        $cur_sence_field = $this->handle_field_arr[$handle_sence];
        if(trim($cur_sence_field) == "*"){
            $this->db_allow_fields = array_keys($this->schemaInfo()->getColumns());
            $this->allow_fields = $this->db_allow_fields;
        }else{
            $this->db_allow_fields = array_keys($this->schemaInfo()->getColumns());
            $this->allow_fields =  array_filter(explode(",",$cur_sence_field));
            foreach ($this->data as $key => $value) {
                if(!in_array($key,$this->allow_fields)){
                    unset($this->data[$key]);
                    unset($post_data[$key]);
                }
            }
        }
        // 数据自动验证-前
        if(!$this->_beforeAutoValidation($post_data,$handle_sence)) return false;
        // 数据自动验证
        if(!$this->_autoValidation($post_data,$handle_sence)) return false;
        // 数据自动验证-后
        if(!$this->_afterAutoValidation($post_data,$handle_sence)) return false;
        // 创建完成对数据进行自动处理
        $this->_logic_auto_fill($post_data);

        if(count($this->data) == 0){
            $this->error = "无修改内容项";
            return false;
        }
        return true;
    }

    protected function _autoValidation($data, $handle_sence){
        // 属性验证
        if(isset($this->logic_validate)) { // 如果设置了数据自动验证则进行数据验证
            if($this->patchValidate) { // 重置验证错误信息
                $this->error = array();
            }
            foreach($this->logic_validate as $key=>$val) {
                // 验证因子定义格式
                // array(field,rule,message,condition,type,when,params)
                // 判断是否需要执行验证
                if(empty($val[5]) || ( $val[5]== self::MODEL_BOTH && $handle_sence < 3 ) || $val[5]== $handle_sence ) {
                    if(0==strpos($val[2],'{%') && strpos($val[2],'}'))
                        // 支持提示信息的多语言 使用 {%语言定义} 方式
                        $val[2]  =  L(substr($val[2],2,-1));
                    $val[3]  =  isset($val[3])?$val[3]:self::EXISTS_VALIDATE;
                    $val[4]  =  isset($val[4])?$val[4]:'regex';
                    // 判断验证条件
                    switch($val[3]) {
                        case self::MUST_VALIDATE:   // 必须验证 不管表单是否有设置该字段
                            if(false === $this->_validationField($data,$val)) 
                                return false;
                            break;
                        case self::VALUE_VALIDATE:    // 值不为空的时候才验证
                            if('' != trim($data[$val[0]]))
                                if(false === $this->_validationField($data,$val)) 
                                    return false;
                            break;
                        default:    // 默认表单存在该字段就验证
                            if(isset($data[$val[0]]))
                                if(false === $this->_validationField($data,$val)) 
                                    return false;
                    }
                }
            }
            // 批量验证的时候最后返回错误
            if(!empty($this->error)) return false;
        }
        return true;
    }

    /**
     * 验证表单字段 支持批量验证
     * 如果批量验证返回错误的数组信息
     * @access protected
     * @param array $data 创建数据
     * @param array $val 验证因子
     * @return boolean
     */
    protected function _validationField($data,$val) {
        if($this->patchValidate && isset($this->error[$val[0]]))
            return ; //当前字段已经有规则验证没有通过
        if(false === $this->_validationFieldItem($data,$val)){
            if($this->patchValidate) {
                $this->error[$val[0]]   =   $val[2];
            }else{
                $this->error            =   $val[2];
                return false;
            }
        }
        return ;
    }

    /**
     * 根据验证因子验证字段
     * @access protected
     * @param array $data 创建数据
     * @param array $val 验证因子
     * @return boolean
     */
    protected function _validationFieldItem($data,$val) {
        if(!isset($data[$val[0]])){
            $this->error = "缺少必要的提交字段:".$val[0];
            return;
        }
        if(false === $data[$val[0]] )   unset($data[$val[0]]);
        switch(strtolower(trim($val[4]))) {
            case 'function':// 使用函数进行验证
            case 'callback':// 调用方法进行验证
                $args = isset($val[6])?(array)$val[6]:array();
                if(is_string($val[0]) && strpos($val[0], ','))
                    $val[0] = explode(',', $val[0]);
                if(is_array($val[0])){
                    // 支持多个字段验证
                    foreach($val[0] as $field)
                        $_data[$field] = $data[$field];
                    array_unshift($args, $_data);
                }else{
                    array_unshift($args, $data[$val[0]]);
                }
                if('function'==$val[4]) {
                    return call_user_func_array($val[1], $args);
                }else{
                    return call_user_func_array(array(&$this, $val[1]), $args);
                }
            default:  // 检查附加规则
                return false;
        }
    }

    protected function _beforeAutoValidation($data, $handle_sence){
        // 因为像orderdetail常在foreach中添加，故此处最好有个初始化。(如特殊情况不需要的，请复写该方法)
        $this->tmp_data = null;
        $this->old_data = null;
        $this->error = null;
        return true;
    }

    protected function _afterAutoValidation($data, $handle_sence) {
        if(defined('IS_DEMO')  && IS_DEMO == true){
            $this->error = "当前系统为演示demo系统，无法进行增删改";
            return false;
        }
        return true;
    }

    private function _logic_auto_fill($data){
        if(isset($this->logic_auto)) {
            foreach ($this->logic_auto as $auto){
                if($auto[2] == $this->handle_sence){
                    if(empty($auto[3])) $auto[3] =  'string';
                    switch(trim($auto[3])) {
                        case 'function':    //  使用函数进行填充 字段的值作为参数
                        case 'callback': // 使用回调方法
                            $args = isset($auto[4])?(array)$auto[4]:array();
                            if(isset($data[$auto[0]])) {
                                array_unshift($args,$data[$auto[0]]);
                            }
                            if('function'==$auto[3]) {
                                if($auto[1] == 'time'){
                                    // 部分函数不需要 参数
                                    $data[$auto[0]]  = call_user_func_array($auto[1],[]);
                                }else{
                                    $data[$auto[0]]  = call_user_func_array($auto[1], $args);
                                }
                            }else{
                                $data[$auto[0]]  =  call_user_func_array(array(&$this,$auto[1]), $args);
                            }
                            break;
                        case 'string':
                        default: // 默认作为字符串填充
                            $data[$auto[0]] = $auto[1];
                    }
                    if(isset($data[$auto[0]]) && false === $data[$auto[0]] )   unset($data[$auto[0]]);

                    if(isset($data[$auto[0]])){
                        if(in_array($auto[0],$this->db_allow_fields)){
                            $this->data[$auto[0]] = $data[$auto[0]];
                        }
                    }
                }
            }
        }
    }
}

```