#!/bin/bash

mongo
echo 'rs.initiate({
      _id: "rs0",
      members: [
         { _id: 0, host: "10.0.15.150" },
         { _id: 1, host: "10.0.15.151" },
         { _id: 2, host: "10.0.15.152", arbiterOnly:false }]});' | mongo
