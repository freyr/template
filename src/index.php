<?php

use Freyr\Template\Initializer;

echo "Hello world! It's Nice here! <br>";
require_once __DIR__ . '/../vendor/autoload.php';

$initializer = new Initializer();
echo "4 + 5 = ". $initializer->add(4,5);
